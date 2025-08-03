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

    boolean success = true;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {

            if (clearParam != null && !clearParam.isBlank()) {
                int tableId = Integer.parseInt(clearParam);
                try (PreparedStatement stmt = con.prepareStatement(
                        "UPDATE tablechart SET status='Available', table_staff_id=NULL, staff_assigned_time=NULL, customer_id=NULL WHERE table_id=?")) {
                    stmt.setInt(1, tableId);
                    stmt.executeUpdate();
                }
            } else if (tableIdParam != null && newStatus != null) {
                int tableId = Integer.parseInt(tableIdParam);
                Integer staffId = (newStaffId != null && !newStaffId.isBlank()) ? Integer.parseInt(newStaffId) : null;

                Integer resolvedCustomerId = null;

                if (customerPhone != null && !customerPhone.isBlank()) {
                    // 1. Check if customer exists
                    String trimmedPhone = customerPhone.trim();
                    try (PreparedStatement lookup = con.prepareStatement("SELECT customer_id, name FROM Customer WHERE phone = ?")) {
                        lookup.setString(1, trimmedPhone);
                        try (ResultSet rs = lookup.executeQuery()) {
                            if (rs.next()) {
                                resolvedCustomerId = rs.getInt("customer_id");
                                String existingName = rs.getString("name");

                                // Update name if it differs
                                if (customerName != null && !customerName.isBlank() && !customerName.trim().equals(existingName)) {
                                    try (PreparedStatement update = con.prepareStatement("UPDATE Customer SET name = ? WHERE customer_id = ?")) {
                                        update.setString(1, customerName.trim());
                                        update.setInt(2, resolvedCustomerId);
                                        update.executeUpdate();
                                    }
                                }
                            }
                        }
                    }

                    // 2. Insert if not found
                    if (resolvedCustomerId == null && customerName != null && !customerName.isBlank()) {
                        try (PreparedStatement insert = con.prepareStatement("INSERT INTO Customer (name, phone) VALUES (?, ?)", Statement.RETURN_GENERATED_KEYS)) {
                            insert.setString(1, customerName.trim());
                            insert.setString(2, trimmedPhone);
                            insert.executeUpdate();
                            try (ResultSet genKeys = insert.getGeneratedKeys()) {
                                if (genKeys.next()) {
                                    resolvedCustomerId = genKeys.getInt(1);
                                }
                            }
                        }
                    }
                }

                if (!"Available".equalsIgnoreCase(newStatus)) {
                    String sql = "UPDATE tablechart SET status=?, table_staff_id=?, staff_assigned_time=CURRENT_TIMESTAMP, customer_id=? WHERE table_id=?";
                    try (PreparedStatement update = con.prepareStatement(sql)) {
                        update.setString(1, newStatus);
                        if (staffId != null) update.setInt(2, staffId);
                        else update.setNull(2, Types.INTEGER);

                        if (resolvedCustomerId != null) update.setInt(3, resolvedCustomerId);
                        else update.setNull(3, Types.INTEGER);

                        update.setInt(4, tableId);
                        update.executeUpdate();
                    }
                } else {
                    try (PreparedStatement stmt = con.prepareStatement(
                            "UPDATE tablechart SET status='Available', table_staff_id=NULL, staff_assigned_time=NULL, customer_id=NULL WHERE table_id=?")) {
                        stmt.setInt(1, tableId);
                        stmt.executeUpdate();
                    }
                }
            }

        }
    } catch (Exception e) {
        success = false;
        out.println("<div style='color:red;'>Update failed: " + e.getMessage() + "</div>");
    }

    if (success) {
        response.sendRedirect("viewTables.jsp");
    }
%>
