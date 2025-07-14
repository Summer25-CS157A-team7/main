<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Login – Enter PIN</title>
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>
  <div class="login-container">
    <h2>Enter Your PIN</h2>

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
      <div class="error"><%= error %></div>
    <% } %>

    <form method="post" action="login">
      <div class="form-group">
        <label for="pin">PIN</label>
        <input type="password"
               id="pin"
               name="pin"
               required
               autofocus
               class="form-control"/>
      </div>
      <div class="form-group">
        <label for="last_name">Last Name</label>
        <input type="text"
               id="last_name"
               name="last_name"
               required
               class="form-control"/>
      </div>
      <button type="submit" class="btn-submit">Submit</button>
    </form>
  </div>
</body>
</html>
