<%@ page import="java.sql.*" %>
<html>
<head><title>View Orders</title></head>
<body>
    <h1>View Orders by Table</h1>

    <!-- View orders for specific table -->
    <form method="get" action="viewTableOrders.jsp">
        <label for="table_id">Enter Table Number:</label>
        <input type="number" name="table_id" required />
        <input type="submit" value="View Orders for Table" />
    </form>

    <br/>

    <!-- View all orders overview -->
    <form method="get" action="viewAllOrders.jsp">
        <input type="submit" value="View All Orders (Overview)" />
    </form>
</body>
</html>
