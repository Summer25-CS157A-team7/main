<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*"
         session="true" %>
<%
    String pin   = request.getParameter("pin");
    String error = null;

    if (pin != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(
                     "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
                     "root", "U75G336w."
                 );
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT Name, Role FROM Login WHERE Pin = ?"
                 )
            ) {
                ps.setString(1, pin);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        // valid PIN → store user info, then redirect
                        session.setAttribute("name", rs.getString("Name"));
                        session.setAttribute("role", rs.getString("Role"));
                        response.sendRedirect("home.jsp");
                        return;
                    } else {
                        error = "Invalid PIN.";
                    }
                }
            }
        } catch (Exception e) {
            error = "Error: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>Login – Enter PIN Please</title>
  <!-- link to your external CSS; make sure this path is valid in your WAR -->
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>
  <div class="login-container">
    <h2>Enter Your PIN</h2>

    <% if (error != null) { %>
      <div class="error"><%= error %></div>
    <% } %>

    <form method="post" action="">
      <div class="form-group">
        <label for="pin">PIN</label>
        <input type="password"
               id="pin"
               name="pin"
               required
               autofocus
               class="form-control"/>
      </div>
      <button type="submit" class="btn-submit">Submit</button>
    </form>
  </div>
</body>
</html>
