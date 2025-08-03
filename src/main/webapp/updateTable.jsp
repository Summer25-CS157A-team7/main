<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>

<%
    String tableIdParam = request.getParameter("table_id");
    String newStatus = request.getParameter("new_status");
    String newStaffId = request.getParameter("new_staff_id");
    String customerName = request.getParameter("customer_name");
    String clearParam = request.getParameter("clear");

    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    if (clearParam != null) {
        int tableId = Integer.parseInt(clearParam);
        PreparedStatement stmt = con.prepareStatement("UPDATE tablechart SET status='Available', table_staff_id=NULL, staff_assigned_time=NULL, customer_id=NULL WHERE table_id=?");
        stmt.setInt(1, tableId);
        stmt.executeUpdate();
        stmt.close();
    } else if (tableIdParam != null && newStatus != null) {
        int tableId = Integer.parseInt(tableIdParam);
        Integer staffId = (newStaffId != null && !newStaffId.isEmpty()) ? Integer.parseInt(newStaffId) : null;

        Integer customerId = null;
        if (customerName != null && !customerName.trim().isEmpty()) {
            PreparedStatement lookup = con.prepareStatement("SELECT customer_id FROM Customer WHERE name = ?");
            lookup.setString(1, customerName.trim());
            ResultSet rs = lookup.executeQuery();
            if (rs.next()) {
                customerId = rs.getInt("customer_id");
            } else {
                PreparedStatement insert = con.prepareStatement("INSERT INTO Customer(name) VALUES (?)", Statement.RETURN_GENERATED_KEYS);
                insert.setString(1, customerName.trim());
                insert.executeUpdate();
                ResultSet keys = insert.getGeneratedKeys();
                if (keys.next()) {
                    customerId = keys.getInt(1);
                }
                keys.close();
                insert.close();
            }
            rs.close();
            lookup.close();
        }

        if (!"Available".equalsIgnoreCase(newStatus)) {
            String updateSQL = "UPDATE tablechart SET status = ?, table_staff_id = ?, staff_assigned_time = CURRENT_TIMESTAMP, customer_id = ? WHERE table_id = ?";
            PreparedStatement updateStmt = con.prepareStatement(updateSQL);
            updateStmt.setString(1, newStatus);
            if (staffId != null) {
                updateStmt.setInt(2, staffId);
            } else {
                updateStmt.setNull(2, java.sql.Types.INTEGER);
            }
            if (customerId != null) {
                updateStmt.setInt(3, customerId);
            } else {
                updateStmt.setNull(3, java.sql.Types.INTEGER);
            }
            updateStmt.setInt(4, tableId);

            updateStmt.executeUpdate();
            updateStmt.close();
        }
    }

    con.close();
    response.sendRedirect("viewTables.jsp");
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    String tableIdStr   = request.getParameter("table_id");
    String clearId      = request.getParameter("clear");
    String newStatus    = request.getParameter("new_status");
    String newStaff     = request.getParameter("new_staff_id");
    String customerName = request.getParameter("customer_name");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/byte2bite?useSSL=false&serverTimezone=UTC",
                "root", "Anderson!!22")) {

            if (clearId != null && !clearId.isBlank()) {
                int clearTableId = Integer.parseInt(clearId);
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE tablechart SET table_staff_id = NULL, status = 'Available', staff_assigned_time = NULL WHERE table_id = ?")) {
                    ps.setInt(1, clearTableId);
                    ps.executeUpdate();
                }
            } else if (tableIdStr != null) {
                int tableId = Integer.parseInt(tableIdStr);
                Integer staffId = (newStaff == null || newStaff.isBlank()) ? null : Integer.parseInt(newStaff);

                // Handle customer name insert if needed
                if (customerName != null && !customerName.isBlank()) {
                    try (PreparedStatement find = con.prepareStatement("SELECT customer_id FROM Customer WHERE name = ?")) {
                        find.setString(1, customerName);
                        ResultSet rs = find.executeQuery();
                        if (!rs.next()) {
                            try (PreparedStatement insert = con.prepareStatement("INSERT INTO Customer (name, phone) VALUES (?, ?)")) {
                                insert.setString(1, customerName);
                                insert.setString(2, "000-000-0000"); // Default phone
                                insert.executeUpdate();
                            }
                        }
                        rs.close();
                    }
                }

                // Always update the table after handling customer logic
                String sql = "UPDATE tablechart SET status = ?, table_staff_id = ?, staff_assigned_time = NOW() WHERE table_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, newStatus);
                    if (staffId != null) {
                        ps.setInt(2, staffId);
                    } else {
                        ps.setNull(2, java.sql.Types.INTEGER);
                    }
                    ps.setInt(3, tableId);
                    ps.executeUpdate();
                }
            }

            response.sendRedirect("viewTables.jsp");

        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Update failed: " + e.getMessage() + "</p>");
    }
%>
