<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";
    String DB_PASSWORD = "Anderson!!22";

    String action = request.getParameter("action");
    int inventoryId = Integer.parseInt(request.getParameter("inventory_id"));
    int sellerId = Integer.parseInt(request.getParameter("seller_id"));

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    if ("update".equals(action)) {
        double cost = Double.parseDouble(request.getParameter("cost"));
        String updateSQL = "UPDATE sold_by SET cost = ? WHERE inventory_id = ? AND seller_id = ?";
        PreparedStatement updateStmt = con.prepareStatement(updateSQL);
        updateStmt.setDouble(1, cost);
        updateStmt.setInt(2, inventoryId);
        updateStmt.setInt(3, sellerId);
        updateStmt.executeUpdate();
        updateStmt.close();
    } else if ("delete".equals(action)) {
        String deleteSQL = "DELETE FROM sold_by WHERE inventory_id = ? AND seller_id = ?";
        PreparedStatement deleteStmt = con.prepareStatement(deleteSQL);
        deleteStmt.setInt(1, inventoryId);
        deleteStmt.setInt(2, sellerId);
        deleteStmt.executeUpdate();
        deleteStmt.close();
    }

    con.close();

    // Redirect back to supplier view
    response.sendRedirect("sellerInfo.jsp");
%>
