<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite – Manage Orders</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">
    <h2>Manage Orders</h2>

    <!-- Filter Form -->
    <form method="get" class="row g-3 mb-4">
        <div class="col-auto">
            <input type="number" name="table_id" class="form-control" placeholder="Filter by Table #" value="<%= request.getParameter("table_id") != null ? request.getParameter("table_id") : "" %>">
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
        </div>
    </form>

    <div class="row">
<%
    String db = "byte2bite";
    String user = "root";
    String password = "Anderson!!22";
    String tableFilter = request.getParameter("table_id");
    String statusFilter = request.getParameter("status_filter");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/" + db + "?autoReconnect=true&useSSL=false",
            user, password
        );

        String query = "SELECT o.order_id, c.customer_id, c.name, o.table_id, o.meal_id, o.status " +
                       "FROM customer c JOIN `order` o USING (customer_id) WHERE 1=1";

        if (tableFilter != null && !tableFilter.trim().isEmpty()) {
            query += " AND o.table_id = " + tableFilter;
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            query += " AND o.status = '" + statusFilter + "'";
        }

        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery(query);

        while (rs.next()) {
            int orderId = rs.getInt("order_id");
            String status = rs.getString("status");
            String statusLabel = "Being Prepared";
            String statusClass = "secondary";
            boolean completeEnabled = false;

            if ("Pending".equalsIgnoreCase(status) || "Preparing".equalsIgnoreCase(status)) {
                statusLabel = "Being Prepared";
                statusClass = "secondary";
            } else if ("Ready".equalsIgnoreCase(status)) {
                statusLabel = "Order Ready";
                statusClass = "info";
                completeEnabled = true;
            } else if ("Completed".equalsIgnoreCase(status)) {
                statusLabel = "Completed";
                statusClass = "success";
            }
%>
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <strong>Order #<%= orderId %></strong>  Table <%= rs.getInt("table_id") %>  <%= rs.getString("name") %>
                </div>
                <div class="card-body">
                    <p>Status: <button class="btn btn-sm btn-<%= statusClass %>" disabled><%= statusLabel %></button></p>
                    <form method="post" action="updateStatus.jsp">
                        <input type="hidden" name="order_id" value="<%= orderId %>" />
                        <input type="hidden" name="new_status" value="Completed" />
                        <button type="submit" class="btn btn-sm btn-success" <%= completeEnabled ? "" : "disabled" %>>Mark as Completed</button>
                    </form>
                </div>
            </div>
        </div>
<%
        }
        rs.close();
        stmt.close();
        con.close();
    } catch (SQLException e) {
        out.println("<p style='color:red;'>SQLException caught: " + e.getMessage() + "</p>");
    } catch (ClassNotFoundException e) {
        out.println("<p style='color:red;'>ClassNotFoundException caught: " + e.getMessage() + "</p>");
    }
%>
    </div>
</body>
</html>