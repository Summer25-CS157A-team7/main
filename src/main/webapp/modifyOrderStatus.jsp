<%@ page import="java.sql.*" %>
<html>
<head>
    <title>Byte2Bite – Manage Orders</title>
</head>
<body>
    <h1>Manage Order Status</h1>
    <table border="1">
        <tr>
            <th>Order ID</th>
            <th>Customer ID</th>
            <th>Name</th>
            <th>Table#</th>
            <th>Meal ID</th>
            <th>Current Status</th>
            <th>Update Status</th>
        </tr>

<%
    String db = "byte2bite";
    String user = "root";
    String password = "Password12!";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
            user, password
        );

        out.println("<p>" + db + " database successfully accessed.</p>");

        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT o.order_id, c.customer_id, c.name, o.table_id, o.meal_id, o.status " +
            "FROM customer c " +
            "JOIN `order` o USING (customer_id)"
        );

        while (rs.next()) {
            int orderId = rs.getInt("order_id");
            String status = rs.getString("status");

            out.println("<tr>" +
                "<td>" + orderId + "</td>" +
                "<td>" + rs.getInt("customer_id") + "</td>" +
                "<td>" + rs.getString("name") + "</td>" +
                "<td>" + rs.getInt("table_id") + "</td>" +
                "<td>" + rs.getInt("meal_id") + "</td>" +
                "<td>" + status + "</td>" +
                "<td>" +
                    "<form method='post' action='updateStatus.jsp'>" +
                        "<input type='hidden' name='order_id' value='" + orderId + "' />" +
                        "<select name='new_status'>" +
                            "<option" + (status.equalsIgnoreCase("Pending") ? " selected" : "") + ">Pending</option>" +
                            "<option" + (status.equalsIgnoreCase("Preparing") ? " selected" : "") + ">Preparing</option>" +
                            "<option" + (status.equalsIgnoreCase("Ready") ? " selected" : "") + ">Ready</option>" +
                            "<option" + (status.equalsIgnoreCase("Serving") ? " selected" : "") + ">Serving</option>" +
                            "<option" + (status.equalsIgnoreCase("Completed") ? " selected" : "") + ">Completed</option>" +
                        "</select>" +
                        "<input type='submit' value='Update' />" +
                    "</form>" +
                "</td>" +
            "</tr>");
        }

        rs.close();
        stmt.close();
        con.close();
    } catch (SQLException e) {
        out.println("<p style='color:red;'>SQLException caught: " + e.getMessage() + "</p>");
    } catch (ClassNotFoundException e) {
        out.println("<p style='color:red;'>ClassNotFoundException caught: " + e.getMessage() + "</p>");
    }
%>
    </table>
</body>
</html>
