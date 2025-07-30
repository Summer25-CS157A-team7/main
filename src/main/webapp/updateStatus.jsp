<%@ page import="java.sql.*" %>
<%
    String db = "byte2bite";
    String user = "root";
    String password = "Anderson!!22";

    String newStatus = request.getParameter("new_status");
    String orderId = request.getParameter("order_id");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
            user, password
        );

        PreparedStatement ps = con.prepareStatement(
            "UPDATE `order` SET status = ? WHERE order_id = ?"
        );
        ps.setString(1, newStatus);
        ps.setInt(2, Integer.parseInt(orderId));

        int updated = ps.executeUpdate();

        ps.close();
        con.close();

        if (updated > 0) {
            response.sendRedirect("viewOrders.jsp"); //
        } else {
            out.println("<p style='color:red;'>Update failed.</p>");
        }

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>
