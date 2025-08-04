<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Inventory Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">

    <div class="position-relative mb-4">
        <a href="managerHub.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0">&larr; Back to Hub</a>
        <h2 class="text-center">Inventory Tracker</h2>
    </div>

    <!-- Filter Form -->
    <form method="get" class="row g-3 mb-4 justify-content-center">
        <div class="col-auto">
            <input type="text" name="ingredient_filter" class="form-control" placeholder="Ingredient Name"
                   value="<%= request.getParameter("ingredient_filter") != null ? request.getParameter("ingredient_filter") : "" %>">
        </div>
        <div class="col-auto">
            <input type="number" name="max_quantity" class="form-control" placeholder="Max Available Quantity"
                   value="<%= request.getParameter("max_quantity") != null ? request.getParameter("max_quantity") : "" %>">
        </div>
        <div class="col-auto">
            <select name="group_by" class="form-select">
                <option value="">Group: None</option>
                <option value="day" <%= "day".equals(request.getParameter("group_by")) ? "selected" : "" %>>Group by Day</option>
                <option value="week" <%= "week".equals(request.getParameter("group_by")) ? "selected" : "" %>>Group by Week</option>
                <option value="month" <%= "month".equals(request.getParameter("group_by")) ? "selected" : "" %>>Group by Month</option>
            </select>
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-primary">Apply Filter</button>
            <a href="InventoryTracker.jsp" class="btn btn-secondary">Clear</a>
        </div>
    </form>

<%
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";
    String DB_PASSWORD = "Anderson!!22";

    String ingredientFilter = request.getParameter("ingredient_filter");
    String maxQtyParam = request.getParameter("max_quantity");
    String groupBy = request.getParameter("group_by");

    Integer maxQty = null;
    if (maxQtyParam != null && !maxQtyParam.trim().isEmpty()) {
        try { maxQty = Integer.parseInt(maxQtyParam.trim()); } catch (NumberFormatException e) {}
    }

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    String query = "SELECT fi.name AS ingredient_name, fi.quantity AS current_quantity, mw.quantity AS used_quantity, m.name AS meal_name, fi.time_stamp " +
                   "FROM food_inventory fi " +
                   "LEFT JOIN made_with mw ON fi.inventory_id = mw.inventory_id " +
                   "LEFT JOIN meal m ON mw.meal_id = m.meal_id " +
                   "WHERE 1=1";

    if (ingredientFilter != null && !ingredientFilter.trim().isEmpty()) {
        query += " AND fi.name LIKE ?";
    }
    if (maxQty != null) {
        query += " AND fi.quantity <= ?";
    }

    query += " ORDER BY fi.time_stamp DESC, fi.name ASC, m.name ASC";

    PreparedStatement stmt = con.prepareStatement(query);

    int paramIndex = 1;
    if (ingredientFilter != null && !ingredientFilter.trim().isEmpty()) {
        stmt.setString(paramIndex++, "%" + ingredientFilter.trim() + "%");
    }
    if (maxQty != null) {
        stmt.setInt(paramIndex++, maxQty);
    }

    ResultSet rs = stmt.executeQuery();

    Map<String, Map<String, Map<String, Integer>>> groupedMap = new LinkedHashMap<>();
    Map<String, Integer> ingredientAvailable = new HashMap<>();

    while (rs.next()) {
        String ingredient = rs.getString("ingredient_name");
        String meal = rs.getString("meal_name");
        int usedQty = rs.getInt("used_quantity");
        int availableQty = rs.getInt("current_quantity");
        Timestamp ts = rs.getTimestamp("time_stamp");
        LocalDate date = ts.toLocalDateTime().toLocalDate();

        String groupKey = "All";
        if ("day".equals(groupBy)) {
            groupKey = date.toString();
        } else if ("week".equals(groupBy)) {
            groupKey = date.with(DayOfWeek.MONDAY).toString() + " (Week)";
        } else if ("month".equals(groupBy)) {
            groupKey = date.getYear() + "-" + String.format("%02d", date.getMonthValue()) + " (Month)";
        }

        ingredientAvailable.put(ingredient, availableQty);
        groupedMap.computeIfAbsent(groupKey, k -> new LinkedHashMap<>());
        Map<String, Map<String, Integer>> group = groupedMap.get(groupKey);

        group.computeIfAbsent(ingredient, k -> new LinkedHashMap<>());
        if (meal != null) {
            group.get(ingredient).put(meal, usedQty);
        }
    }

    rs.close();
    stmt.close();
    con.close();
%>

    <div class="accordion" id="accordionInventory">
        <% int index = 0;
        for (Map.Entry<String, Map<String, Map<String, Integer>>> groupedEntry : groupedMap.entrySet()) {
            String groupLabel = groupedEntry.getKey();
            Map<String, Map<String, Integer>> ingredientMap = groupedEntry.getValue();
        %>
        <div class="accordion-item">
            <h2 class="accordion-header" id="heading<%= index %>">
                <button class="accordion-button <%= index > 0 ? "collapsed" : "" %>" type="button"
                        data-bs-toggle="collapse" data-bs-target="#collapse<%= index %>">
                    <%= groupLabel %>
                </button>
            </h2>
            <div id="collapse<%= index %>" class="accordion-collapse collapse <%= index == 0 ? "show" : "" %>"
                 data-bs-parent="#accordionInventory">
                <div class="accordion-body">
                    <table class="table table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>Ingredient</th>
                                <th>Used In</th>
                                <th>Amount Used</th>
                                <th>Available Quantity</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (Map.Entry<String, Map<String, Integer>> ing : ingredientMap.entrySet()) {
                            String ingredient = ing.getKey();
                            Map<String, Integer> meals = ing.getValue();
                            int available = ingredientAvailable.getOrDefault(ingredient, 0);
                            boolean firstRow = true;
                            for (Map.Entry<String, Integer> m : meals.entrySet()) {
                        %>
                            <tr>
                                <% if (firstRow) { %>
                                    <td rowspan="<%= meals.size() %>"><%= ingredient %></td>
                                <% } %>
                                <td><%= m.getKey() %></td>
                                <td><%= m.getValue() %></td>
                                <% if (firstRow) { %>
                                    <td rowspan="<%= meals.size() %>"><%= available %></td>
                                <% } %>
                            </tr>
                        <% firstRow = false; } } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <% index++; } %>
    </div>
</body>
</html>
