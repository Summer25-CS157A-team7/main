<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Ingredient Supplier Mapping</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterIngredients() {
            const input = document.getElementById("filterInput").value.toLowerCase();
            const items = document.querySelectorAll(".accordion-item");

            items.forEach(item => {
                const text = item.innerText.toLowerCase();
                item.style.display = text.includes(input) ? "" : "none";
            });
        }

        function clearFilter() {
            document.getElementById("filterInput").value = "";
            filterIngredients();
        }
    </script>
</head>
<body class="container mt-5">
    <div class="position-relative mb-4">
        <a href="managerHub.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0">&larr; Back to Hub</a>
        <h2 class="text-center">Ingredients & Their Suppliers</h2>
    </div>

    <!-- Filter -->
    <div class="mb-4 text-center d-flex justify-content-center gap-2">
        <input id="filterInput" type="text" class="form-control w-50" placeholder="Filter by ingredient or supplier..." onkeyup="filterIngredients()">
        <button class="btn btn-secondary" onclick="clearFilter()">Clear</button>
    </div>

    <div class="accordion" id="accordionIngredients">
        <%
            String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
            String DB_USER = "root";
            String DB_PASSWORD = "Anderson!!22";

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

            String sql = "SELECT f.inventory_id, f.name AS ingredient, " +
                         "s.seller_id, s.name AS supplier_name, s.phone, sb.cost " +
                         "FROM food_inventory f " +
                         "JOIN sold_by sb ON f.inventory_id = sb.inventory_id " +
                         "JOIN supplier s ON sb.seller_id = s.seller_id " +
                         "ORDER BY f.name, s.name";

            PreparedStatement stmt = con.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            // Group by ingredient
            Map<Integer, Map<String, Object>> ingredientMap = new LinkedHashMap<>();

            while (rs.next()) {
                int inventoryId = rs.getInt("inventory_id");

                if (!ingredientMap.containsKey(inventoryId)) {
                    Map<String, Object> ingredientData = new HashMap<>();
                    ingredientData.put("name", rs.getString("ingredient"));
                    ingredientData.put("sellers", new ArrayList<Map<String, Object>>());
                    ingredientMap.put(inventoryId, ingredientData);
                }

                List<Map<String, Object>> sellerList = (List<Map<String, Object>>) ingredientMap.get(inventoryId).get("sellers");

                Map<String, Object> seller = new HashMap<>();
                seller.put("seller_id", rs.getInt("seller_id"));
                seller.put("supplier_name", rs.getString("supplier_name"));
                seller.put("phone", rs.getString("phone"));
                seller.put("cost", rs.getDouble("cost"));
                sellerList.add(seller);
            }

            rs.close();
            stmt.close();
            con.close();

            int index = 0;
            for (Map.Entry<Integer, Map<String, Object>> entry : ingredientMap.entrySet()) {
                int inventoryId = entry.getKey();
                Map<String, Object> data = entry.getValue();
                String ingredientName = (String) data.get("name");
                List<Map<String, Object>> sellers = (List<Map<String, Object>>) data.get("sellers");
        %>
        <div class="accordion-item">
            <h2 class="accordion-header" id="heading<%= index %>">
                <button class="accordion-button <%= index > 0 ? "collapsed" : "" %>" type="button" data-bs-toggle="collapse" data-bs-target="#collapse<%= index %>">
                    <%= ingredientName %>
                </button>
            </h2>
            <div id="collapse<%= index %>" class="accordion-collapse collapse <%= index == 0 ? "show" : "" %>" data-bs-parent="#accordionIngredients">
                <div class="accordion-body">
                    <ul class="list-group">
                        <% for (Map<String, Object> seller : sellers) {
                            int sellerId = (Integer) seller.get("seller_id");
                            String supplierName = (String) seller.get("supplier_name");
                            String phone = (String) seller.get("phone");
                            double cost = (Double) seller.get("cost");
                        %>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            <span>
                                <strong><%= supplierName %></strong>
                                <span class="text-muted ms-2">(<%= phone %>)</span>
                            </span>
                            <form method="post" action="updateSelleritem.jsp" class="d-flex gap-2">
                                <input type="hidden" name="inventory_id" value="<%= inventoryId %>">
                                <input type="hidden" name="seller_id" value="<%= sellerId %>">
                                <input type="number" step="0.01" name="cost" class="form-control form-control-sm" value="<%= cost %>" required>
                                <button type="submit" name="action" value="update" class="btn btn-sm btn-success">Update</button>
                                <button type="submit" name="action" value="delete" class="btn btn-sm btn-danger">Remove</button>
                            </form>
                        </li>
                        <% } %>
                    </ul>
                </div>
            </div>
        </div>
        <% index++; } %>
    </div>
</body>
</html>
