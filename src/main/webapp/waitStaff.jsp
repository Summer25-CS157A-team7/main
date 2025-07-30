<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<html>
<head>
    <title>Byte2Bite – Waitstaff Order Entry</title>
</head>
<body>
    <h1>Enter a New Order</h1>

    <form method="post" action="submitOrder.jsp">
        <label>Table Number:</label>
        <input type="number" name="table_id" required /><br/><br/>

        <table border="1">
            <tr>
                <th>Select</th>
                <th>Meal ID</th>
                <th>Meal Name</th>
            </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
            "root", "Anderson!!22"
        );

        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT meal_id, name FROM meal");

        while (rs.next()) {
            int mealId = rs.getInt("meal_id");
            String mealName = rs.getString("name");

            out.println("<tr>");
            out.println("<td><input type='checkbox' name='meal_ids' value='" + mealId + "' /></td>");
            out.println("<td>" + mealId + "</td>");
            out.println("<td>" + mealName + "</td>");
            out.println("</tr>");
        }

        rs.close();
        stmt.close();
        con.close();
    } catch (Exception e) {
        out.println("<tr><td colspan='3' style='color:red;'>Error loading meals: " + e.getMessage() + "</td></tr>");
    }
%>
        </table><br/>

        <input type="submit" value="Submit Order" />
    </form>
</body>
</html>
