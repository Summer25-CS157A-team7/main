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
%>
