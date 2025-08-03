<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String tableIdParam = request.getParameter("table_id");
    String newStatus = request.getParameter("new_status");
    String newStaffId = request.getParameter("new_staff_id");
    String customerName = request.getParameter("customer_name");
    String customerPhone = request.getParameter("customer_phone"); // phone is PK now
    String clearParam = request.getParameter("clear");

    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASSWORD = "Password12!"; // exact, no trailing spaces

    boolean success = true;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {

            if (clearParam != null && !clearParam.isBlank()) {
                int tableId = Integer.parseInt(clearParam);
                try (PreparedStatement stmt = con.prepareStatement(
                        "UPDATE tablechart SET status='Available', table_staff_id=NULL, staff_assigned_time=NULL, customer_phone=NULL WHERE table_id=?")) {
                    stmt.setInt(1, tableId);
                    stmt.executeUpdate();
                }
            } else if (tableIdParam != null && newStatus != null) {
                int tableId = Integer.parseInt(tableIdParam);
                Integer staffId = (newStaffId != null && !newStaffId.isBlank()) ? Integer.parseInt(newStaffId) : null;

                String resolvedPhone = null;
                if (customerPhone != null && !customerPhone.isBlank()) {
                    resolvedPhone = customerPhone.trim();

                    // Check if customer exists by phone
                    boolean customerExists = false;
                    String existingName = null;
                    try (PreparedStatement lookup = con.prepareStatement("SELECT name FROM Customer WHERE phone = ?")) {
                        lookup.setString(1, resolvedPhone);
                        try (ResultSet rs = lookup.executeQuery()) {
                            if (rs.next()) {
                                customerExists = true;
                                existingName = rs.getString("name");
                            }
                        }
                    }

                    // If exists and provided name differs, update name
                    if (customerExists && customerName != null && !customerName.isBlank()) {
                        String trimmedName = customerName.trim();
                        if (!trimmedName.equals(existingName)) {
                            try (PreparedStatement updName = con.prepareStatement(
                                    "UPDATE Customer SET name = ? WHERE phone = ?")) {
                                updName.setString(1, trimmedName);
                                updName.setString(2, resolvedPhone);
                                updName.executeUpdate();
                            }
                        }
                    }

                    // Insert new customer if doesn't exist
                    if (!customerExists && customerName != null && !customerName.isBlank()) {
                        try (PreparedStatement insert = con.prepareStatement(
                                "INSERT INTO Customer(name, phone) VALUES (?, ?)")) {
                            insert.setString(1, customerName.trim());
                            insert.setString(2, resolvedPhone);
                            insert.executeUpdate();
                        }
                    }
                }

                if (!"Available".equalsIgnoreCase(newStatus)) {
                    String updateSQL = "UPDATE tablechart SET status = ?, table_staff_id = ?, staff_assigned_time = CURRENT_TIMESTAMP, customer_phone = ? WHERE table_id = ?";
                    try (PreparedStatement updateStmt = con.prepareStatement(updateSQL)) {
                        updateStmt.setString(1, newStatus);
                        if (staffId != null) {
                            updateStmt.setInt(2, staffId);
                        } else {
                            updateStmt.setNull(2, Types.INTEGER);
                        }
                        if (resolvedPhone != null) {
                            updateStmt.setString(3, resolvedPhone);
                        } else {
                            updateStmt.setNull(3, Types.VARCHAR);
                        }
                        updateStmt.setInt(4, tableId);
                        updateStmt.executeUpdate();
                    }
                } else {
                    // Setting to Available clears assignments
                    try (PreparedStatement stmt = con.prepareStatement(
                            "UPDATE tablechart SET status='Available', table_staff_id=NULL, staff_assigned_time=NULL, customer_phone=NULL WHERE table_id=?")) {
                        stmt.setInt(1, tableId);
                        stmt.executeUpdate();
                    }
                }
            }

        }
    } catch (Exception e) {
        success = false;
        out.println("<div style='color:red; padding:1rem; background:#ffe6e6; border:1px solid red;'>Update failed: " + e.getMessage() + "</div>");
    }

    if (success) {
        response.sendRedirect("viewTables.jsp");
    }
%>
