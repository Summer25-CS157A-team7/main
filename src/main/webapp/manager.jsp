<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    String firstName = (String) session.getAttribute("FirstName");
    String lastName = (String) session.getAttribute("LastName");
    String role = (String) session.getAttribute("role");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manager Page</title>
</head>
<body>
    <h2>Welcome, <%= firstName %> <%= lastName %>! You’ve successfully logged in as <%= role %>.</h2>
</body>
</html>
