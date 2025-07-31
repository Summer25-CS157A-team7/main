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
    <link rel="stylesheet" href="/byte2bite-web/css/manager.css?v=<%= System.currentTimeMillis() %>" />
</head>
<body>
    <div class="user-info"> <%= role %> : <%= firstName %> <%= lastName %></div>

    <form action="register_employee.jsp" method="get">
    <button type="submit" class="btn">
        Register Employees
    </button>
    </form>

    <form action="manage_employee.jsp" method="get">
    <button type="submit" class="btn">
        Manage Employees
    </button>
    </form>

    <form action="viewTables.jsp" method="get">
    <button type="submit" class="btn">
        Manage Table
    </button>
    </form>


</body>
</html>
