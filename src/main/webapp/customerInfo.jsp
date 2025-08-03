<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Customer Info</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">

     <!-- Back Button -->
    <div class="position-relative mb-4">
        <a href="managerHub.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0" style="z-index:1;">&larr; Back to Hub</a>
        <h2 class="text-center">Customer Info</h2>
    </div>


    <!-- Filter Form -->
    <form method="get" class="row g-3 mb-4 justify-content-center">
        <div class="col-auto">
            <input type="text" name="name_filter" class="form-control" placeholder="Customer Name" value="<%= request.getParameter("name_filter") != null ? request.getParameter("name_filter") : "" %>">
        </div>
        <div class="col-auto">
            <input type="text" name="phone_filter" class="form-control" placeholder="Phone Number" value="<%= request.getParameter("phone_filter") != null ? request.getParameter("phone_filter") : "" %>">
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-primary">Apply Filter</button>
            <a href="customerInfo.jsp" class="btn btn-secondary">Clear</a>
        </div>
    </form>

<%
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";
    String DB_PASSWORD = "Anderson!!22";

    String nameFilter = request.getParameter("name_filter");
    String phoneFilter = request.getParameter("phone_filter");

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    String query = "SELECT c.customer_id, c.name, c.phone, " +
               "o.order_id, o.status AS order_status, o.table_id AS order_table_id, m.name AS meal_name " +
               "FROM Customer c " +
               "LEFT JOIN `Order` o ON o.customer_id = c.customer_id " +
               "LEFT JOIN made_with AS oc ON o.meal_id = oc.meal_id " +  
               "LEFT JOIN Meal m ON m.meal_id = oc.meal_id " +
               "WHERE 1=1";

    if (nameFilter != null && !nameFilter.trim().isEmpty()) {
        query += " AND c.name LIKE '%" + nameFilter.trim() + "%'";
    }
    if (phoneFilter != null && !phoneFilter.trim().isEmpty()) {
        query += " AND c.phone LIKE '%" + phoneFilter.trim() + "%'";
    }

    query += " ORDER BY c.name ASC, o.order_id ASC";

    Statement stmt = con.createStatement();
    ResultSet rs = stmt.executeQuery(query);

    Map<Integer, Map<String, Object>> customers = new LinkedHashMap<>();

    while (rs.next()) {
        int custId = rs.getInt("customer_id");
        String name = rs.getString("name");
        String phone = rs.getString("phone");
        Integer orderId = rs.getObject("order_id") != null ? rs.getInt("order_id") : null;
        String orderStatus = rs.getString("order_status");
        Integer orderTableId = rs.getObject("order_table_id") != null ? rs.getInt("order_table_id") : null;
        String mealName = rs.getString("meal_name");

        Map<String, Object> custData = customers.computeIfAbsent(custId, k -> {
            Map<String, Object> m = new HashMap<>();
            m.put("name", name);
            m.put("phone", phone);
            m.put("orders", new LinkedHashMap<Integer, Map<String, Object>>());
            return m;
        });

        Map<Integer, Map<String, Object>> orders = (Map<Integer, Map<String, Object>>) custData.get("orders");
        if (orderId != null) {
            Map<String, Object> orderData = orders.computeIfAbsent(orderId, k -> {
                Map<String, Object> om = new HashMap<>();
                om.put("status", orderStatus);
                om.put("table", orderTableId != null ? "Table #" + orderTableId : "No Table");
                om.put("items", new LinkedHashSet<String>()); // prevent duplicates
                return om;
            });
            if (mealName != null) {
                Set<String> items = (Set<String>) orderData.get("items");
                items.add(mealName);
            }
        }
    }
    rs.close();
    stmt.close();
    con.close();
%>

    <div class="row justify-content-center">
        <div class="col-md-10">
<% for (Map.Entry<Integer, Map<String, Object>> entry : customers.entrySet()) {
       int customerId = entry.getKey();
       Map<String, Object> data = entry.getValue();
       Map<Integer, Map<String, Object>> orders = (Map<Integer, Map<String, Object>>) data.get("orders");
%>
            <div class="card mb-3">
                <div class="card-header" data-bs-toggle="collapse" data-bs-target="#cust-<%= customerId %>">
                    <strong><%= data.get("name") %></strong> | <%= data.get("phone") %>
                </div>
                <div id="cust-<%= customerId %>" class="collapse card-body">
                    <p><strong>Customer ID:</strong> <%= customerId %></p>

                    <% if (!orders.isEmpty()) { %>
                        <label><strong>Order History:</strong></label>
                        <% for (Map.Entry<Integer, Map<String, Object>> o : orders.entrySet()) { %>
                            <div class="card my-2">
                                <div class="card-header" data-bs-toggle="collapse" data-bs-target="#order-<%= o.getKey() %>">
                                    Order #<%= o.getKey() %> (<%= o.getValue().get("status") %>) — <%= o.getValue().get("table") %>
                                </div>
                                <div id="order-<%= o.getKey() %>" class="collapse card-body">
                                    <ul class="mb-0">
                                        <% for (String item : (Set<String>) o.getValue().get("items")) { %>
                                            <li><%= item %></li>
                                        <% } %>
                                    </ul>
                                </div>
                            </div>
                        <% } %>
                    <% } else { %>
                        <p class="text-muted">No orders found.</p>
                    <% } %>
                </div>
            </div>
<% } %>
        </div>
    </div>
</body>
</html>
