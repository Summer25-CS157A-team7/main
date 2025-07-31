<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         import="java.sql.*, java.util.*" %>
<%
    String firstName = (String) session.getAttribute("FirstName");
    String lastName  = (String) session.getAttribute("LastName");
    String role      = (String) session.getAttribute("role");

    
    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER     = "root";
    String DB_PASSWORD = "Password12!";

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    Map<Integer,String> staffMap = new LinkedHashMap<>();
    Statement staffStmt = con.createStatement();
    ResultSet staffRs = staffStmt.executeQuery(
        "SELECT s.staff_id, s.first_name, s.last_name FROM Staff s JOIN staff_role r ON s.staff_id = r.staff_id WHERE r.role_name = 'Wait Staff' ORDER BY s.last_name, s.first_name");

    while (staffRs.next()) 
    {
        int id = staffRs.getInt("staff_id");
        String name = staffRs.getString("first_name") + " "+ staffRs.getString("last_name");
        staffMap.put(id, name);
    }
    staffRs.close();
    staffStmt.close();

    Statement stmt = con.createStatement();
    ResultSet rs = stmt.executeQuery(
        "SELECT table_id, capacity, table_staff_id, status FROM tablechart");
%>
<html>
<head>
    <title>Manage Table Status</title>
    <link rel="stylesheet"
          href="/byte2bite-web/css/viewTables.css?v=<%= System.currentTimeMillis() %>" />
</head>
<body>
    <div class="user-info">
        <%= role %> : <%= firstName %> <%= lastName %>
    </div>
    <h1>Manage Table Status</h1>
    <table border="1">
        <tr>
            <th>Table #</th>
            <th>Capacity</th>
            <th>Assigned Staff</th>
            <th>Status</th>
        </tr>
<%
    out.println("<form method='post' action='updateTable.jsp'>");

    while (rs.next()) {
        int tableId = rs.getInt("table_id");
        int cap     = rs.getInt("capacity");
        int staffId = rs.getInt("table_staff_id");
        String status = rs.getString("status");

        out.println("  <tr>");
        out.println("    <td>" + tableId + "</td>");
        out.println("    <td>" + cap + "</td>");

       
        out.println("    <td>");
        out.println("      <input type='hidden' name='table_id' value='" + tableId + "' />");
        out.println("      <select name='new_staff_id'>");
        for (Map.Entry<Integer,String> e : staffMap.entrySet()) {
            String sel = (e.getKey() == staffId) ? "selected" : "";
            out.println("        <option value='" + e.getKey() + "' " + sel + ">" + e.getValue() + "</option>");
        }
        out.println("      </select>");
        out.println("    </td>");


        out.println("    <td>");
        out.println("      <select name='new_status'>");
        for (String s : new String[] {"Available","Occupied","Reserved"}) {
            String sel2 = s.equalsIgnoreCase(status) ? "selected" : "";
            out.println("        <option value='" + s + "' " + sel2 + ">" + s + "</option>");
        }
        out.println("      </select>");
        out.println("    </td>");

        out.println("  </tr>");
    }

    out.println("</table>");
    out.println("<input type='submit' value='Update' />");
    out.println("</form>");
%>