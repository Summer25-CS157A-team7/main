<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Login – Enter PIN</title>
  <link rel="stylesheet" href="/byte2bite-web/css/style.css?v=<%= System.currentTimeMillis() %>" />

</head>
<body>

  <header>
    <img src="${pageContext.request.contextPath}/images/logo.png" alt="Logo"/>
    <div class="brand-name">Byte2Bite</div>
  </header>
  
  <div class="login-container">
    <h2>Enter Your Login</h2>

    <form method="post" action="${pageContext.request.contextPath}/login">
      <div class="form-group">
        <label for="staff_id">Staff ID</label>
        <input
          type="text"
          id="staff_id"
          name="staff_id"
          required
          autofocus
          class="form-control"/>
      </div>

      <div class="form-group">
        <label for="pin">PIN</label>
        <input
          type="password"
          id="pin"
          name="pin"
          required
          class="form-control"/>
      </div>

      <button type="submit" class="btn-Login">Login</button>
    </form>
  </div>
</body>
</html>