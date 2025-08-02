<%@ page import="java.sql.*" %>
<%@ page import="java.time.*, java.time.temporal.*, java.time.format.*" %>
<%
    String DB_USER = "root";
    String DB_PASSWORD = "Anderson!!22";
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?useSSL=false&serverTimezone=UTC";

    String filter = request.getParameter("filter");
    String tableFilter = request.getParameter("table_id");
    String whereClause = "";
    boolean hasPrevious = false;

    if ("active".equalsIgnoreCase(filter)) {
        whereClause += "WHERE o.status IN ('Pending', 'Preparing')";
        hasPrevious = true;
    } else if ("completed".equalsIgnoreCase(filter)) {
        whereClause += "WHERE o.status = 'Completed'";
        hasPrevious = true;
    }

    if (tableFilter != null && !tableFilter.trim().isEmpty()) {
        if (hasPrevious) {
            whereClause += " AND o.table_id = " + tableFilter;
        } else {
            whereClause += "WHERE o.table_id = " + tableFilter;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Order View</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">
    <h2>Order Completion overview</h2>

    <form method="get" class="row g-3 mb-4">
        <div class="col-md-4">
            <label class="form-label">Filter by Status</label>
            <select name="filter" class="form-select">
                <option value="">All</option>
                <option value="active" <%= "active".equalsIgnoreCase(filter) ? "selected" : "" %>>Active (Pending/Preparing)</option>
                <option value="completed" <%= "completed".equalsIgnoreCase(filter) ? "selected" : "" %>>Completed</option>
            </select>
        </div>
        <div class="col-md-4">
            <label class="form-label">Filter by Table</label>
            <input type="number" name="table_id" class="form-control" value="<%= tableFilter != null ? tableFilter : "" %>" placeholder="Enter Table #" />
        </div>
        <div class="col-md-2 d-flex align-items-end">
            <button type="submit" class="btn btn-primary w-100">Apply</button>
        </div>
    </form>

<%
    try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
         PreparedStatement ps = conn.prepareStatement(
            "SELECT o.order_id, o.status, o.time_stamp, m.name AS meal_name, t.table_id " +
            "FROM `order` o " +
            "JOIN meal m ON o.meal_id = m.meal_id " +
            "JOIN tablechart t ON o.table_id = t.table_id " +
            whereClause +
            " ORDER BY o.time_stamp DESC"
        );
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            int orderId = rs.getInt("order_id");
            String status = rs.getString("status");
            String mealName = rs.getString("meal_name");
            int tableId = rs.getInt("table_id");
            Timestamp timeStamp = rs.getTimestamp("time_stamp");

            long minutesAgo = 0;
            if (timeStamp != null) {
                ZonedDateTime orderTime = timeStamp.toInstant().atZone(ZoneId.systemDefault());
                ZonedDateTime now = ZonedDateTime.now(ZoneId.systemDefault());
                Duration duration = Duration.between(orderTime, now);
                minutesAgo = duration.toMinutes();
            }

            String badgeClass = switch (status) {
                case "Preparing" -> "warning";
                case "Completed" -> "success";
                default -> "secondary";
            };
%>
    <div class="card mb-3">
        <div class="card-header d-flex justify-content-between align-items-center">
            <span>
                <strong>Order #<%= orderId %></strong>  <%= mealName %>
                <small class="text-muted">(Table <%= tableId %>, <%= minutesAgo %> min ago)</small>
            </span>
            <span class="badge bg-<%= badgeClass %>"><%= status %></span>
        </div>
    </div>
<%
        }
    } catch (Exception e) {
%>
    <p class="text-danger">Error: <%= e.getMessage() %></p>
<%
    }
%>

</body>
</html>
