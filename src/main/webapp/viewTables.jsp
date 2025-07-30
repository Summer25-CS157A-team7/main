<%@ page import="java.sql.*" %>
<html>
<head><title>Manage Table Status</title></head>
<body>
    <h1>Manage Table Status</h1>

    <table border="1">
        <tr>
            <th>Table #</th>
            <th>Capacity</th>
            <th>Assigned Staff ID</th>
            <th>Status</th>
            <th>Update</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
            "root", "Anderson!!22"
        );

        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT table_id, capacity, table_staff_id, status FROM tablechart");

        while (rs.next()) {
            int tableId = rs.getInt("table_id");
            int cap = rs.getInt("capacity");
            int staffId = rs.getInt("table_staff_id");
            String status = rs.getString("status");

            out.println("<tr>");
            out.println("<td>" + tableId + "</td>");
            out.println("<td>" + cap + "</td>");
            out.println("<td>" + staffId + "</td>");
            out.println("<td>" + status + "</td>");
            out.println("<td>");
            out.println("<form method='post' action='updateTableStatus.jsp'>");
            out.println("<input type='hidden' name='table_id' value='" + tableId + "' />");
            out.println("<select name='new_status'>");
            for (String s : new String[] {"Available", "Occupied", "Reserved"}) {
                String selected = s.equalsIgnoreCase(status) ? "selected" : "";
                out.println("<option value='" + s + "' " + selected + ">" + s + "</option>");
            }
            out.println("</select>");
            out.println("<input type='submit' value='Update' />");
            out.println("</form>");
            out.println("</td>");
            out.println("</tr>");
        }

        rs.close();
        stmt.close();
        con.close();
    } catch (Exception e) {
        out.println("<tr><td colspan='5' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
    }
%>
    </table>
</body>
</html>
