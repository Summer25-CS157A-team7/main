<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
            <input type="text" name="ingredient_filter" class="form-control" placeholder="Ingredient Name" value="<%= request.getParameter("ingredient_filter") != null ? request.getParameter("ingredient_filter") : "" %>">
        </div>
        <div class="col-auto">
            <input type="number" name="min_quantity" class="form-control" placeholder="Min Available Quantity" value="<%= request.getParameter("min_quantity") != null ? request.getParameter("min_quantity") : "" %>">
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-primary">Apply Filter</button>
            <a href="inventoryTracker.jsp" class="btn btn-secondary">Clear</a>
        </div>
    </form>

<%
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";
    String DB_PASSWORD = "Anderson!!22";

    String ingredientFilter = request.getParameter("ingredient_filter");
    String minQtyParam = request.getParameter("min_quantity");
    Integer minQty = null;
    if (minQtyParam != null && !minQtyParam.trim().isEmpty()) {
        try { minQty = Integer.parseInt(minQtyParam.trim()); } catch (NumberFormatException e) { minQty = null; }
    }

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    String query = "SELECT fi.name AS ingredient_name, fi.quantity AS current_quantity, mw.quantity AS used_quantity, m.name AS meal_name " +
                   "FROM food_inventory fi " +
                   "LEFT JOIN made_with mw ON fi.inventory_id = mw.inventory_id " +
                   "LEFT JOIN meal m ON mw.meal_id = m.meal_id " +
                   "WHERE 1=1";

    if (ingredientFilter != null && !ingredientFilter.trim().isEmpty()) {
        query += " AND fi.name LIKE ?";
    }
    if (minQty != null) {
        query += " AND fi.quantity >= ?";
    }

    query += " ORDER BY fi.name ASC, m.name ASC";

    PreparedStatement stmt = con.prepareStatement(query);

    int paramIndex = 1;
    if (ingredientFilter != null && !ingredientFilter.trim().isEmpty()) {
        stmt.setString(paramIndex++, "%" + ingredientFilter.trim() + "%");
    }
    if (minQty != null) {
        stmt.setInt(paramIndex++, minQty);
    }

    ResultSet rs = stmt.executeQuery();

    Map<String, Map<String, Integer>> inventoryMap = new LinkedHashMap<>();
    Map<String, Integer> ingredientTotal = new LinkedHashMap<>();

    while (rs.next()) {
        String ingredient = rs.getString("ingredient_name");
        String meal = rs.getString("meal_name");
        int usedQty = rs.getInt("used_quantity");
        int availableQty = rs.getInt("current_quantity");

        ingredientTotal.put(ingredient, availableQty);

        if (meal != null) {
            inventoryMap.computeIfAbsent(ingredient, k -> new LinkedHashMap<>()).put(meal, usedQty);
        }
    }
    rs.close();
    stmt.close();
    con.close();
%>

    <div class="table-responsive">
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
            <% for (Map.Entry<String, Map<String, Integer>> entry : inventoryMap.entrySet()) {
                String ingredient = entry.getKey();
                Map<String, Integer> meals = entry.getValue();
                int available = ingredientTotal.getOrDefault(ingredient, 0);
                boolean firstRow = true;
                for (Map.Entry<String, Integer> mealEntry : meals.entrySet()) {
            %>
                <tr>
                    <% if (firstRow) { %>
                        <td rowspan="<%= meals.size() %>"><%= ingredient %></td>
                    <% } %>
                    <td><%= mealEntry.getKey() %></td>
                    <td><%= mealEntry.getValue() %></td>
                    <% if (firstRow) { %>
                        <td rowspan="<%= meals.size() %>"><%= available %></td>
                    <% } %>
                </tr>
            <% firstRow = false; } } %>
            </tbody>
        </table>
    </div>
</body>
</html>
