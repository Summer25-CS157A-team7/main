<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%
    String pin = request.getParameter("pin");
    String error = null;

    if (pin != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
                "root",
                "U75G336w."
            );

            Statement stmt = con.createStatement();

            String sql = "SELECT * FROM Login WHERE Pin = '" + pin + "'";
            ResultSet rs = stmt.executeQuery(sql);

            if (rs.next()) {
            	error = "Valid PIN";
            	String name = rs.getString("Name");
            	String role = rs.getString("Role");
            	
            	response.sendRedirect("home.jsp");
            
            	session.setAttribute("name", name);
            	session.setAttribute("role", role);
            	 
            } else {
                error = "Invalid PIN.";
            }

            con.close();

        } catch (Exception e) {
            error = "Error: " + e.getMessage();
        }
    }
%>


<html>
    <head>
        <title>Login Page</title>
    </head>
    <body>
        <h2>Enter Your Pin</h2>

    <% if (error != null) { %> <p style="color:red;"><%= error %></p> <% } %>

    <form method="post">
        PIN: <input type="password" name="pin" /><br/><br/>
        <input type="submit" value="Submit" />
    </form>
    </body>
</html>



