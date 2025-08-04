<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String tableIdParam = request.getParameter("table_id");
    String newStatus = request.getParameter("new_status");
    String newStaffId = request.getParameter("new_staff_id");
    String customerName = request.getParameter("customer_name");
    String customerPhone = request.getParameter("customer_phone");
    String clearParam = request.getParameter("clear");

    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASSWORD = "Password12!";
    boolean success = true;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {

            con.setAutoCommit(false); // transaction boundary

            if (clearParam != null && !clearParam.isBlank()) {
                int tableId = Integer.parseInt(clearParam);

                // fetch current session_id to close
                Long existingSessionId = null;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT session_id FROM TableChart WHERE table_id = ?")) {
                    ps.setInt(1, tableId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            Object sid = rs.getObject("session_id");
                            if (sid != null) {
                                existingSessionId = rs.getLong("session_id");
                            }
                        }
                    }
                }

                // close open session (closed_at NULL means open)
                if (existingSessionId != null) {
                    try (PreparedStatement closeSess = con.prepareStatement(
                            "UPDATE sessions SET closed_at=CURRENT_TIMESTAMP WHERE session_id=? AND closed_at IS NULL")) {
                        closeSess.setLong(1, existingSessionId);
                        closeSess.executeUpdate();
                    }
                }

                // clear table and null out session_id
                try (PreparedStatement stmt = con.prepareStatement(
                        "UPDATE TableChart SET status='Available', table_staff_id=NULL, staff_assigned_time=NULL, customer_phone=NULL, session_id=NULL WHERE table_id=?")) {
                    stmt.setInt(1, tableId);
                    stmt.executeUpdate();
                }

            } else if (tableIdParam != null && newStatus != null) {
                int tableId = Integer.parseInt(tableIdParam);
                Integer staffId = (newStaffId != null && !newStaffId.isBlank()) ? Integer.parseInt(newStaffId) : null;

                // fetch current table status and session_id
                String currentTableStatus = null;
                Long currentSessionId = null;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT status, session_id FROM TableChart WHERE table_id = ?")) {
                    ps.setInt(1, tableId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            currentTableStatus = rs.getString("status");
                            Object sid = rs.getObject("session_id");
                            if (sid != null) currentSessionId = rs.getLong("session_id");
                        }
                    }
                }

                // customer upsert
                String resolvedCustomerPhone = null;
                if (customerPhone != null && !customerPhone.isBlank()) {
                    String trimmedPhone = customerPhone.trim();
                    boolean customerExists = false;
                    try (PreparedStatement lookup = con.prepareStatement("SELECT name FROM Customer WHERE phone = ?")) {
                        lookup.setString(1, trimmedPhone);
                        try (ResultSet rs = lookup.executeQuery()) {
                            if (rs.next()) {
                                customerExists = true;
                                String existingName = rs.getString("name");
                                if (customerName != null && !customerName.isBlank() && !customerName.trim().equals(existingName)) {
                                    try (PreparedStatement update = con.prepareStatement("UPDATE Customer SET name = ? WHERE phone = ?")) {
                                        update.setString(1, customerName.trim());
                                        update.setString(2, trimmedPhone);
                                        update.executeUpdate();
                                    }
                                }
                            }
                        }
                    }
                    if (!customerExists && customerName != null && !customerName.isBlank()) {
                        try (PreparedStatement insert = con.prepareStatement("INSERT INTO Customer (phone, name) VALUES (?, ?)")) {
                            insert.setString(1, trimmedPhone);
                            insert.setString(2, customerName.trim());
                            insert.executeUpdate();
                        }
                    }
                    resolvedCustomerPhone = trimmedPhone;
                }

                if (!"Available".equalsIgnoreCase(newStatus)) {
                    // create a new session if coming from Available/no session
                    if ((currentSessionId == null || "Available".equalsIgnoreCase(currentTableStatus)) && staffId != null) {
                        try (PreparedStatement insertSession = con.prepareStatement(
                                "INSERT INTO sessions (table_id, staff_id) VALUES (?, ?)",
                                Statement.RETURN_GENERATED_KEYS)) {
                            insertSession.setInt(1, tableId);
                            insertSession.setInt(2, staffId);
                            insertSession.executeUpdate();
                            try (ResultSet gen = insertSession.getGeneratedKeys()) {
                                if (gen.next()) {
                                    currentSessionId = gen.getLong(1);
                                }
                            }
                        }
                    }

                    // update table with new occupancy/reservation and session_id
                    String sql = "UPDATE TableChart SET status=?, table_staff_id=?, staff_assigned_time=CURRENT_TIMESTAMP, customer_phone=?, session_id=? WHERE table_id=?";
                    try (PreparedStatement update = con.prepareStatement(sql)) {
                        update.setString(1, newStatus);
                        if (staffId != null) update.setInt(2, staffId);
                        else update.setNull(2, Types.INTEGER);

                        if (resolvedCustomerPhone != null) update.setString(3, resolvedCustomerPhone);
                        else update.setNull(3, Types.VARCHAR);

                        if (currentSessionId != null) update.setLong(4, currentSessionId);
                        else update.setNull(4, Types.BIGINT);

                        update.setInt(5, tableId);
                        update.executeUpdate();
                    }
                } else {
                    // transition back to Available: close session and clear
                    if (currentSessionId != null) {
                        try (PreparedStatement closeSess = con.prepareStatement(
                                "UPDATE sessions SET closed_at=CURRENT_TIMESTAMP WHERE session_id=? AND closed_at IS NULL")) {
                            closeSess.setLong(1, currentSessionId);
                            closeSess.executeUpdate();
                        }
                    }
                    try (PreparedStatement stmt = con.prepareStatement(
                            "UPDATE TableChart SET status='Available', table_staff_id=NULL, staff_assigned_time=NULL, customer_phone=NULL, session_id=NULL WHERE table_id=?")) {
                        stmt.setInt(1, tableId);
                        stmt.executeUpdate();
                    }
                }
            }

            con.commit();
        }
    } catch (Exception e) {
        success = false;
        out.println("<div style='color:red;'>Update failed: " + e.getMessage() + "</div>");
    }

    if (success) {
        response.sendRedirect("viewTables.jsp");
    }
%>
