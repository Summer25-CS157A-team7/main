<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%String name = (String) session.getAttribute("name");%>
<%String role = (String) session.getAttribute("role");%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Page</title>
</head>
<body>
     <h2>Welcome, <%= name %>! You’ve successfully logged in321312 as test test <%= role %> .</h2>
</body>
</html>
