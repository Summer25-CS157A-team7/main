<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Manage Orders</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">

    <!-- Back Button Row -->
    <div class="mb-2">
        <a href="employeeHub.jsp" class="btn btn-outline-secondary">&larr; Back to Hub</a>
    </div>

    <!-- Centered Title -->
    <div class="text-center mb-4">
        <h2>Order Status</h2>
    </div>


    <!-- Filter Form -->
    <form method="get" class="row g-3 mb-4 justify-content-center">
        <div class="col-auto">
            <input type="number" name="table_id" class="form-control" placeholder="Filter by Table #" value="<%= request.getParameter("table_id") != null ? request.getParameter("table_id") : "" %>">
        </div>
        <div class="col-auto">
            <input type="number" name="order_id" class="form-control" placeholder="Filter by Order #" value="<%= request.getParameter("order_id") != null ? request.getParameter("order_id") : "" %>">
        </div>
        <div class="col-auto">
            <select name="status_filter" class="form-select">
                <option value="">All Status</option>
                <option value="Pending" <%= "Pending".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Pending</option>
                <option value="Preparing" <%= "Preparing".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Being Prepared</option>
                <option value="Ready" <%= "Ready".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Order Ready</option>
                <option value="Completed" <%= "Completed".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Completed</option>
            </select>
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-primary">Apply Filter</button>
            <a href="modifyOrderStatus.jsp" class="btn btn-secondary">Clear Filter</a>
        </div>
    </form>

<%
    String db = "byte2bite";
    String user = "root";
    String password = "Anderson!!22";
    String tableFilter = request.getParameter("table_id");
    String statusFilter = request.getParameter("status_filter");
    String orderIdFilter = request.getParameter("order_id");

    List<String> activeStatuses = Arrays.asList("Pending", "Preparing", "Ready");
    List<Map<String, Object>> activeOrders = new ArrayList<>();
    List<Map<String, Object>> completedOrders = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/" + db + "?autoReconnect=true&useSSL=false", user, password);

        String query = "SELECT o.order_id, c.customer_id, c.name, o.table_id, o.status, m.name AS meal_name, m.category, m.price " +
                       "FROM customer c JOIN `order` o USING (customer_id) JOIN meal m ON o.meal_id = m.meal_id WHERE 1=1";

        if (tableFilter != null && !tableFilter.trim().isEmpty()) {
            query += " AND o.table_id = " + tableFilter;
        }
        if (orderIdFilter != null && !orderIdFilter.trim().isEmpty()) {
            query += " AND o.order_id = " + orderIdFilter;
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            query += " AND o.status = '" + statusFilter + "'";
        }

        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery(query);

        while (rs.next()) {
            Map<String, Object> order = new HashMap<>();
            order.put("order_id", rs.getInt("order_id"));
            order.put("status", rs.getString("status"));
            order.put("table_id", rs.getInt("table_id"));
            order.put("customer_name", rs.getString("name"));
            order.put("meal_name", rs.getString("meal_name"));
            order.put("category", rs.getString("category"));
            order.put("price", rs.getDouble("price"));

            if ("Completed".equalsIgnoreCase((String) order.get("status"))) {
                completedOrders.add(order);
            } else {
                activeOrders.add(order);
            }
        }
        rs.close();
        stmt.close();
        con.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>

    <div class="row justify-content-center">
        <div class="col-md-6">
            <h4 class="mb-3">Active Orders</h4>
<% for (Map<String, Object> order : activeOrders) {
    String status = (String) order.get("status");
    String statusLabel = "Being Prepared";
    String statusClass = "secondary";
    boolean completeEnabled = false;

    if ("Ready".equalsIgnoreCase(status)) {
        statusLabel = "Order Ready";
        statusClass = "info";
        completeEnabled = true;
    } else if ("Completed".equalsIgnoreCase(status)) {
        statusLabel = "Completed";
        statusClass = "success";
    }
%>
            <div class="card mb-3">
                <div class="card-header">
                    <strong>Order #<%= order.get("order_id") %></strong> | Table <%= order.get("table_id") %> | <%= order.get("customer_name") %>
                </div>
                <div class="card-body">
                    <p>Status: <button class="btn btn-sm btn-<%= statusClass %>" disabled><%= statusLabel %></button></p>
                    <form method="post" action="updateStatus.jsp">
                        <input type="hidden" name="order_id" value="<%= order.get("order_id") %>" />
                        <input type="hidden" name="new_status" value="Completed" />
                        <button type="submit" class="btn btn-sm btn-success" <%= completeEnabled ? "" : "disabled" %>>Mark as Completed</button>
                    </form>
                </div>
            </div>
<% } %>

            <h4 class="mt-5 mb-3">Completed Orders</h4>
<% for (Map<String, Object> order : completedOrders) { %>
            <div class="card mb-3">
                <div class="card-header collapsed" data-bs-toggle="collapse" data-bs-target="#collapse-<%= order.get("order_id") %>" style="cursor:pointer;">
                    <strong>Order #<%= order.get("order_id") %></strong> | Table <%= order.get("table_id") %> | <%= order.get("customer_name") %> <span class="text-success">Completed</span>
                </div>
                <div id="collapse-<%= order.get("order_id") %>" class="collapse card-body">
                    <p>Meal: <%= order.get("meal_name") %> (<%= order.get("category") %>)</p>
                    <p>Price: $<%= String.format("%.2f", order.get("price")) %></p>
                </div>
            </div>
<% } %>
        </div>
    </div>
</body>
</html>
