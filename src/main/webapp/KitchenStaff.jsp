<%@ page import="java.sql.*" %>
<%@ page import="java.time.*, java.time.temporal.*, java.time.format.*" %>

<%
    String DB_USER = "root";
    String DB_PASSWORD = "Anderson!!22";
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?useSSL=false&serverTimezone=UTC";

    // Handle status update
    String updateId = request.getParameter("update_order_id");
    String newStatus = request.getParameter("new_status");

    if (updateId != null && newStatus != null) {
        try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
             PreparedStatement ps = conn.prepareStatement("UPDATE `order` SET status=? WHERE order_id=?")) {
            ps.setString(1, newStatus);
            ps.setInt(2, Integer.parseInt(updateId));
            ps.executeUpdate();

            response.sendRedirect("kitchenView.jsp");
            return;
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error updating status: " + e.getMessage() + "</p>");
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Kitchen Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">
    <h2> Active Orders</h2>

<%
    try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
         PreparedStatement ps = conn.prepareStatement(
             "SELECT o.order_id, o.status, o.time_stamp, m.name AS meal_name " +
             "FROM `order` o " +
             "JOIN meal m USING (meal_id) " +
             "WHERE o.status IN ('Pending', 'Preparing') " +
             "ORDER BY o.order_id"
         );
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            int orderId = rs.getInt("order_id");
            String status = rs.getString("status");
            String mealName = rs.getString("meal_name");
            Timestamp timeStamp = rs.getTimestamp("time_stamp");
            long minutesAgo = 0;
            if (timeStamp != null) {
                
                // Convert to local time zone
                ZonedDateTime orderTime = timeStamp.toInstant().atZone(ZoneId.systemDefault());
                ZonedDateTime now = ZonedDateTime.now(ZoneId.systemDefault());
                Duration duration = Duration.between(orderTime, now);
                minutesAgo = duration.toMinutes();
            }
%>
    <div class="card mb-3">
        <div class="card-header d-flex justify-content-between align-items-center">
            <span>
                <strong>Order #<%= orderId %></strong>  <%= mealName %> (<%= status %>)
                <small class="text-muted"> Ordered <%= minutesAgo %> min ago</small>
            </span>
            <div>
                <!-- Preparing Button -->
                <form method="post" class="d-inline">
                    <input type="hidden" name="update_order_id" value="<%= orderId %>">
                    <input type="hidden" name="new_status" value="Preparing">
                    <button class="btn btn-sm btn-warning"
                            type="submit"
                            <%= status.equals("Preparing") || status.equals("Ready") ? "disabled" : "" %>>
                        Preparing
                    </button>
                </form>

                <!-- Ready Button -->
                <form method="post" class="d-inline ms-2">
                    <input type="hidden" name="update_order_id" value="<%= orderId %>">
                    <input type="hidden" name="new_status" value="Ready">
                    <button class="btn btn-sm btn-success"
                            type="submit"
                            <%= status.equals("Pending") || status.equals("Ready") ? "disabled" : "" %>>
                        Ready
                    </button>
                </form>

                <!-- Ingredients Toggle -->
                <button class="btn btn-sm btn-outline-secondary ms-2"
                        data-bs-toggle="collapse"
                        data-bs-target="#ingredients-<%= orderId %>">
                    Ingredients
                </button>
            </div>
        </div>
        <div id="ingredients-<%= orderId %>" class="collapse card-body">
            <table class="table table-bordered table-sm">
                <tr><th>Ingredient</th><th>Quantity</th></tr>
<%
                try (PreparedStatement ps2 = conn.prepareStatement(
                        "SELECT fi.name, mw.quantity FROM made_with mw " +
                        "JOIN food_inventory fi USING (inventory_id) " +
                        "JOIN `order` o USING (meal_id) " +
                        "WHERE o.order_id = ?")) {
                    ps2.setInt(1, orderId);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        while (rs2.next()) {
%>
                <tr>
                    <td><%= rs2.getString("name") %></td>
                    <td><%= rs2.getInt("quantity") %></td>
                </tr>
<%
                        }
                    }
                }
%>
            </table>
        </div>
    </div>
<%
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading active orders: " + e.getMessage() + "</p>");
    }
%>

<hr class="my-5">
<h4 class="mb-3">Completed Orders</h4>

<%
    try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
         PreparedStatement ps = conn.prepareStatement(
             "SELECT o.order_id, o.time_stamp, m.name AS meal_name " +
             "FROM `order` o " +
             "JOIN meal m USING (meal_id) " +
             "WHERE o.status = 'Ready' " +
             "ORDER BY o.order_id"
         );
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            int orderId = rs.getInt("order_id");
            String mealName = rs.getString("meal_name");
            Timestamp timeStamp = rs.getTimestamp("time_stamp");

            long minutesAgo = 0;
            if (timeStamp != null) {
                long now = System.currentTimeMillis();
                long diffMillis = now - timeStamp.getTime();
                minutesAgo = diffMillis / (60 * 1000);
            }
%>
    <div class="card mb-3">
        <div class="card-header d-flex justify-content-between align-items-center">
            <span>
                <strong>Order #<%= orderId %></strong> <%= mealName %> (Ready)
                <small class="text-muted"> Ordered <%= minutesAgo %> min ago</small>
            </span>
            <button class="btn btn-sm btn-outline-success"
                    data-bs-toggle="collapse"
                    data-bs-target="#ready-<%= orderId %>">
                Ingredients
            </button>
        </div>
        <div id="ready-<%= orderId %>" class="collapse card-body">
            <table class="table table-striped table-sm">
                <tr><th>Ingredient</th><th>Quantity</th></tr>
<%
                try (PreparedStatement ps2 = conn.prepareStatement(
                        "SELECT fi.name, mw.quantity FROM made_with mw " +
                        "JOIN food_inventory fi USING (inventory_id) " +
                        "JOIN `order` o USING (meal_id) " +
                        "WHERE o.order_id = ?")) {
                    ps2.setInt(1, orderId);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        while (rs2.next()) {
%>
                <tr>
                    <td><%= rs2.getString("name") %></td>
                    <td><%= rs2.getInt("quantity") %></td>
                </tr>
<%
                        }
                    }
                }
%>
            </table>
        </div>
    </div>
<%
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading ready orders: " + e.getMessage() + "</p>");
    }
%>

</body>
</html>
