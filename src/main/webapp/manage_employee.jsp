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


    String newRole = request.getParameter("new_role");
    String staffIdToUpdate = request.getParameter("staff_id");

    if (newRole != null && staffIdToUpdate != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps2 = conn.prepareStatement("UPDATE staff_role SET role_name=? WHERE staff_id=?")) {
                ps2.setString(1, newRole);
                ps2.setInt(2, Integer.parseInt(staffIdToUpdate));
                ps2.executeUpdate();
                out.println("<p style='color:green;'>Role updated!</p>");
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error updating role: " + e.getMessage() + "</p>");
        }
    }
%>


<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manager Page</title>
    <link rel="stylesheet" href="/byte2bite-web/css/manage_employee.css?v=<%= System.currentTimeMillis() %>" />
</head>
<body>

    <div class="user-info">
        <%= role %> : <%= firstName %> <%= lastName %>
    </div>

    <h3>Active Employees</h3>
    <%

        String sql = "SELECT s.staff_id, s.first_name, s.last_name, r.role_name FROM Staff s JOIN staff_role r ON s.staff_id = r.staff_id WHERE s.staff_id NOT IN ( SELECT staff_id  FROM staff_role WHERE role_name = 'Admin' OR role_name = 'Manager' OR role_name = 'Terminated') ORDER BY s.staff_id";
        try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
    %>
    <table>
        <div class="employee-tables">
        <tr>
            <th><strong>Staff ID</strong></th>
            <th><strong>First Name</strong></th>
            <th><strong>Last Name</strong></th>
            <th><strong>Role</strong></th>
        </tr>
        <%
            while (rs.next()) {
                int staffId = rs.getInt("staff_id");
                String fName = rs.getString("first_name");
                String lName = rs.getString("last_name");
                String roleName = rs.getString("role_name");
        %>
        <tr>
            <td><%= staffId %></td>
            <td><%= fName %></td>
            <td><%= lName %></td>
            <td>
                <form method="post">
                    <input type="hidden" name="staff_id" value="<%= staffId %>">
                    <div class="custom-select">
                    <select name="new_role" onchange="this.form.submit()">
                        <option value="Wait Staff" <%= "Wait Staff".equals(roleName) ? "selected" : "" %>>Wait Staff</option>
                        <option value="Kitchen Staff" <%= "Kitchen Staff".equals(roleName) ? "selected" : "" %>>Kitchen Staff</option>
                        <option value="Terminated" <%= "Terminated".equals(roleName) ? "selected" : "" %>>Terminated</option>
                    </select>
                    </div>
                </form>
            </td>
        </tr>
        <%
            }
        %>
        </div>
    </table>
    <%
        } catch (Exception e) {
    %>
        <p style="color:red;">Error loading active employees: <%= e.getMessage() %></p>
    <%
        }
    %>

    <h4>Terminated Employees</h4>
    <%
        String sqlTerminated =
            "SELECT s.staff_id, s.first_name, s.last_name, r.role_name " +
            "FROM Staff s " +
            "JOIN staff_role r ON s.staff_id = r.staff_id " +
            "WHERE r.role_name = 'Terminated' ORDER BY s.staff_id";
        try (Connection conn2 = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
             PreparedStatement ps2 = conn2.prepareStatement(sqlTerminated);
             ResultSet rs2 = ps2.executeQuery()) { 
    %>
    <table>
        <div class="employee-tables">
        <tr>
            <th><strong>Staff ID</strong></th>
            <th><strong>First Name</strong></th>
            <th><strong>Last Name</strong></th>
            <th><strong>Role</strong></th>
        </tr>
        <%
            while (rs2.next()) {
                int staffId = rs2.getInt("staff_id");
                String fName = rs2.getString("first_name");
                String lName = rs2.getString("last_name");

        %>
        <tr>
            <td><%= staffId %></td>
            <td><%= fName %></td>
            <td><%= lName %></td>
            <td>
                <form method="post">
                    <input type="hidden" name="staff_id" value="<%= staffId %>">
                    <div class="custom-select">
                    <select name="new_role" onchange="this.form.submit()">
                        <option value="" disabled selected>Terminated</option>
                        <option value="Wait Staff">Wait Staff</option>
                        <option value="Kitchen Staff">Kitchen Staff</option>
                    </select>
                    </div>
                </form>
            </td>
        </tr>
        <%
            }
        %>
        </div>
    </table>
    <%
        } catch (Exception e) {
    %>
        <p style="color:red;">Error loading terminated employees: <%= e.getMessage() %></p>
    <%
        }
    %>
</body>
</html>