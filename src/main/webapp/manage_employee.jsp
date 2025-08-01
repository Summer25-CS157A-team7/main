<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         import="java.sql.*" %>
<%
    // --- Session info ---
    String firstName = (String) session.getAttribute("FirstName");
    String lastName  = (String) session.getAttribute("LastName");
    String role      = (String) session.getAttribute("role");

    // --- JDBC settings ---
    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER     = "root";
    String DB_PASSWORD = "ADD YOUR PASSWORD";

    // --- Update role ---
    String newRole = request.getParameter("new_role");
    String staffIdToUpdate = request.getParameter("staff_id");

    if (newRole != null && staffIdToUpdate != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn2 = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps2 = conn2.prepareStatement("UPDATE staff_role SET role_name=? WHERE staff_id=?")) {
                
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
    <style>
      table { border-collapse: collapse; width: 80%; margin-top: 20px; }
      th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
      th { background: #eee; }
    </style>
</head>
<body>
    <h2>Welcome, <%= firstName %> <%= lastName %>! You’ve successfully logged in as <%= role %>.</h2>

    <h3>All Employees</h3>
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
            <th>Change Role</th>
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
            <td><%= roleName %></td>
            <td>
                <form method="post">
                    <input type="hidden" name="staff_id" value="<%= staffId %>">
                    <select name="new_role">
                        <option value="Admin" <%= roleName.equals("Admin") ? "selected" : "" %>>Admin</option>
                        <option value="Manager" <%= roleName.equals("Manager") ? "selected" : "" %>>Manager</option>
                        <option value="Wait Staff" <%= roleName.equals("Wait Staff") ? "selected" : "" %>>Wait Staff</option>
                        <option value="Kitchen Staff" <%= roleName.equals("Kitchen Staff") ? "selected" : "" %>>Kitchen Staff</option>
                    </select>
                    <button type="submit">Update</button>
                </form>
            </td>
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
