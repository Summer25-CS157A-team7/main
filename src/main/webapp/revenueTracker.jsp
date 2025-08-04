<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Revenue Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">

    <div class="position-relative mb-4">
        <a href="managerHub.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0">&larr; Back to Hub</a>
        <h2 class="text-center">Revenue Report</h2>
    </div>

    <!-- Filter Form -->
    <form method="get" class="row g-3 mb-4 justify-content-center">
        <div class="col-auto">
            <label class="form-label">From:</label>
            <input type="date" name="start_date" class="form-control" value="<%= request.getParameter("start_date") != null ? request.getParameter("start_date") : "" %>">
        </div>
        <div class="col-auto">
            <label class="form-label">To:</label>
            <input type="date" name="end_date" class="form-control" value="<%= request.getParameter("end_date") != null ? request.getParameter("end_date") : "" %>">
        </div>
        <div class="col-auto">
            <label class="form-label">Transaction #:</label>
            <input type="number" name="txn_id" class="form-control" placeholder="e.g. 101" value="<%= request.getParameter("txn_id") != null ? request.getParameter("txn_id") : "" %>">
        </div>
        <div class="col-auto">
            <label class="form-label">Group By:</label>
            <select name="group_by" class="form-select">
                <option value="" <%= request.getParameter("group_by") == null ? "selected" : "" %>>None</option>
                <option value="day" <%= "day".equals(request.getParameter("group_by")) ? "selected" : "" %>>Day</option>
                <option value="week" <%= "week".equals(request.getParameter("group_by")) ? "selected" : "" %>>Week</option>
                <option value="month" <%= "month".equals(request.getParameter("group_by")) ? "selected" : "" %>>Month</option>
            </select>
        </div>
        <div class="col-auto align-self-end">
            <button type="submit" class="btn btn-primary">Apply Filters</button>
            <a href="revenueTracker.jsp" class="btn btn-secondary">Clear</a>
        </div>
    </form>

<%
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";
    String DB_PASSWORD = "Anderson!!22";

    String startDate = request.getParameter("start_date");
    String endDate = request.getParameter("end_date");
    String groupBy = request.getParameter("group_by");
    String txnIdParam = request.getParameter("txn_id");

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    String baseQuery = "SELECT t.Transaction_id, t.subtotal, t.time_stamp, m.name AS meal_name, m.price AS meal_price, c.quantity " +
                       "FROM transaction t " +
                       "JOIN `order` o ON t.Transaction_id = o.transaction_id " +
                       "JOIN made_with c ON o.meal_id = c.meal_id " +
                       "JOIN meal m ON c.meal_id = m.meal_id " +
                       "WHERE 1=1";

    List<String> conditions = new ArrayList<>();
    if (startDate != null && !startDate.trim().isEmpty()) {
        conditions.add("t.time_stamp >= ?");
    }
    if (endDate != null && !endDate.trim().isEmpty()) {
        conditions.add("t.time_stamp <= ?");
    }
    if (txnIdParam != null && !txnIdParam.trim().isEmpty()) {
        conditions.add("t.Transaction_id = ?");
    }
    for (String cond : conditions) {
        baseQuery += " AND " + cond;
    }

    baseQuery += " ORDER BY t.time_stamp ASC";

    PreparedStatement stmt = con.prepareStatement(baseQuery);
    int paramIdx = 1;
    if (startDate != null && !startDate.trim().isEmpty()) stmt.setString(paramIdx++, startDate);
    if (endDate != null && !endDate.trim().isEmpty()) stmt.setString(paramIdx++, endDate);
    if (txnIdParam != null && !txnIdParam.trim().isEmpty()) stmt.setInt(paramIdx++, Integer.parseInt(txnIdParam));

    ResultSet rs = stmt.executeQuery();

    Map<String, List<Map<String, Object>>> groupedData = new LinkedHashMap<>();
    double totalRevenue = 0.0;
    Set<Integer> seenTransactionIds = new HashSet<>();

    while (rs.next()) {
        String groupKey;
        Timestamp ts = rs.getTimestamp("time_stamp");
        LocalDate date = ts.toLocalDateTime().toLocalDate();
        if ("week".equals(groupBy)) {
            groupKey = date.with(DayOfWeek.MONDAY).toString() + " (Week)";
        } else if ("month".equals(groupBy)) {
            groupKey = date.getYear() + "-" + String.format("%02d", date.getMonthValue()) + " (Month)";
        } else if ("day".equals(groupBy)) {
            groupKey = date.toString();
        } else {
            groupKey = "All Transactions";
        }

        groupedData.computeIfAbsent(groupKey, k -> new ArrayList<>());

        int txnId = rs.getInt("Transaction_id");

        Map<String, Object> record = new HashMap<>();
        record.put("transaction_id", txnId);
        record.put("subtotal", rs.getDouble("subtotal"));
        record.put("time_stamp", ts);
        record.put("meal_name", rs.getString("meal_name"));
        record.put("meal_price", rs.getDouble("meal_price"));
        record.put("quantity", rs.getInt("quantity"));

        groupedData.get(groupKey).add(record);

        if (!seenTransactionIds.contains(txnId)) {
            totalRevenue += rs.getDouble("subtotal");
            seenTransactionIds.add(txnId);
        }
    }

    rs.close();
    stmt.close();
    con.close();
%>

    <!-- Total Revenue Display -->
    <div class="mb-4 text-center">
        <h4 class="text-success">Total Revenue: $<%= String.format("%.2f", totalRevenue) %></h4>
    </div>

    <!-- Accordion Display -->
    <div class="accordion" id="accordionRevenue">
        <% int index = 0;
        for (Map.Entry<String, List<Map<String, Object>>> entry : groupedData.entrySet()) {
            String label = entry.getKey();
            List<Map<String, Object>> transactions = entry.getValue();
        %>
        <div class="accordion-item">
            <h2 class="accordion-header" id="heading<%= index %>">
                <button class="accordion-button <%= index > 0 ? "collapsed" : "" %>" type="button" data-bs-toggle="collapse" data-bs-target="#collapse<%= index %>">
                    <%= label %>
                </button>
            </h2>
            <div id="collapse<%= index %>" class="accordion-collapse collapse <%= index == 0 ? "show" : "" %>" data-bs-parent="#accordionRevenue">
                <div class="accordion-body">
                    <% Map<Integer, List<Map<String, Object>>> transactionMap = new LinkedHashMap<>();
                    for (Map<String, Object> r : transactions) {
                        Integer tid = (Integer) r.get("transaction_id");
                        transactionMap.computeIfAbsent(tid, k -> new ArrayList<>()).add(r);
                    }
                    for (Map.Entry<Integer, List<Map<String, Object>>> group : transactionMap.entrySet()) {
                        List<Map<String, Object>> details = group.getValue();
                        double subtotal = (double) details.get(0).get("subtotal");
                        Timestamp ts = (Timestamp) details.get(0).get("time_stamp");
                    %>
                    <div class="card my-2">
                        <div class="card-header" data-bs-toggle="collapse" data-bs-target="#txn<%= group.getKey() %>">
                            Transaction #<%= group.getKey() %> <%= ts.toString() %>
                        </div>
                        <div id="txn<%= group.getKey() %>" class="collapse card-body">
                            <p><strong>Total:</strong> $<%= String.format("%.2f", subtotal) %></p>
                            <ul class="mb-0">
                                <% for (Map<String, Object> d : details) {
                                    int qty = (int) d.get("quantity");
                                    double price = (double) d.get("meal_price");
                                    String mealName = (String) d.get("meal_name");
                                %>
                                <li><%= mealName %> — $<%= String.format("%.2f", qty * price) %></li>
                                <% } %>
                            </ul>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
        <% index++; } %>
    </div>
</body>
</html>
