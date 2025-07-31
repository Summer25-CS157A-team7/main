<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         import="java.sql.*" %>
<%

    String firstName = (String) session.getAttribute("FirstName");
    String lastName  = (String) session.getAttribute("LastName");
    String role      = (String) session.getAttribute("role");


    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER     = "root";
    String DB_PASSWORD = "Password12!";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manager Page</title>
     <link rel="stylesheet" href="/byte2bite-web/css/manage_employee.css?v=<%= System.currentTimeMillis() %>" />
    <style>
      table { border-collapse: collapse; width: 80%; margin-top: 20px; }
      th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
      th { background: #eee; }
    </style>
</head>
<body>
    <div class="user-info"> <%= role %> : <%= firstName %> <%= lastName %></div>
    
    <h3>Employees List</h3>
    <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

            String sql = ""
                + "SELECT s.staff_id, s.first_name, s.last_name, r.role_name "
                + "FROM Staff s "
                + "  JOIN staff_role r ON s.staff_id = r.staff_id "
                + "ORDER BY s.staff_id";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
    %>
    <table>
        <tr>
            <th>Staff ID</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Role</th>
        </tr>
        <%
            while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("staff_id") %></td>
            <td><%= rs.getString("first_name") %></td>
            <td><%= rs.getString("last_name") %></td>
            <td><%= rs.getString("role_name") %></td>
        </tr>
        <%
            }
        %>
    </table>
    <%
        } catch (Exception e) {
    %>
        <p style="color:red;">Error loading employees: <%= e.getMessage() %></p>
    <%
        } finally {
            if (rs  != null) try { rs.close();  } catch (SQLException ignore){}
            if (ps  != null) try { ps.close();  } catch (SQLException ignore){}
            if (conn!= null) try { conn.close();} catch (SQLException ignore){}
        }
    %>
</body>
</html>
