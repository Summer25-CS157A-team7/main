<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Table Availability</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">
    <div class="text-center">
        <h2>Table Availability</h2>
    </div>

    <!-- Filter Form -->
    <form method="get" class="row g-3 mb-4 justify-content-center">
        <div class="col-auto">
            <input type="number" name="capacity_filter" class="form-control" placeholder="# of Guests" value="<%= request.getParameter("capacity_filter") != null ? request.getParameter("capacity_filter") : "" %>">
        </div>
        <div class="col-auto">
            <select name="status_filter" class="form-select">
                <option value="">All Statuses</option>
                <option value="Available" <%= "Available".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Available</option>
                <option value="Occupied" <%= "Occupied".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Occupied</option>
                <option value="Reserved" <%= "Reserved".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Reserved</option>
            </select>
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-primary">Apply Filter</button>
            <a href="viewTables.jsp" class="btn btn-secondary">Clear Filter</a>
        </div>
    </form>

<%
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";

    String capacityFilter = request.getParameter("capacity_filter");
    String statusFilter = request.getParameter("status_filter");

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    Map<Integer,String> staffMap = new LinkedHashMap<>();
    Statement staffStmt = con.createStatement();
    ResultSet staffRs = staffStmt.executeQuery("SELECT s.staff_id, s.first_name, s.last_name FROM Staff s JOIN staff_role r ON s.staff_id = r.staff_id WHERE r.role_name = 'Wait Staff' ORDER BY s.last_name, s.first_name");

    while (staffRs.next()) {
        int id = staffRs.getInt("staff_id");
        String name = staffRs.getString("first_name") + " " + staffRs.getString("last_name");
        staffMap.put(id, name);
    }
    staffRs.close();
    staffStmt.close();

    Map<Integer, String> customerMap = new HashMap<>();
    Statement custStmt = con.createStatement();
    ResultSet custRs = custStmt.executeQuery("SELECT customer_id, name FROM Customer");
    while (custRs.next()) {
        customerMap.put(custRs.getInt("customer_id"), custRs.getString("name"));
    }
    custRs.close();
    custStmt.close();

    int guests = -1;
    if (capacityFilter != null && !capacityFilter.isEmpty()) {
        try {
            guests = Integer.parseInt(capacityFilter);
        } catch (NumberFormatException ignored) {}
    }

    String query = "SELECT table_id, capacity, status, table_staff_id, staff_assigned_time, customer_id FROM tablechart WHERE 1=1";
    if (statusFilter != null && !statusFilter.isEmpty()) {
        query += " AND status = '" + statusFilter + "'";
    }
    if (guests > 0) {
        query += " AND capacity >= " + guests;
    }
    query += " ORDER BY status ASC, capacity ASC";

    Statement stmt = con.createStatement();
    ResultSet rs = stmt.executeQuery(query);
%>
    <div class="row justify-content-center">
        <div class="col-md-6">
<%
    while (rs.next()) {
        int tableId = rs.getInt("table_id");
        int cap = rs.getInt("capacity");
        int staffIdRaw = rs.getInt("table_staff_id");
        Integer staffId = (!rs.wasNull()) ? staffIdRaw : null;
        String status = rs.getString("status");
        int customerId = rs.getInt("customer_id");
        String customerName = customerMap.getOrDefault(customerId, "");
        Timestamp assignedTs = rs.getTimestamp("staff_assigned_time");

        String assignedAgo = "n/a";
        if (assignedTs != null) {
            Instant assignedInstant = assignedTs.toInstant();
            Duration d = Duration.between(assignedInstant, Instant.now());
            long hours = d.toHoursPart();
            long minutes = d.toMinutesPart();
            if (hours > 0) {
                assignedAgo = hours + "h " + minutes + "m ago";
            } else {
                assignedAgo = minutes + "m ago";
            }
        }

        String bgClass = "bg-success text-white";
        if ("Reserved".equalsIgnoreCase(status)) bgClass = "bg-warning";
        else if ("Occupied".equalsIgnoreCase(status)) bgClass = "bg-danger text-white";
%>
            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center <%= bgClass %>" data-bs-toggle="collapse" data-bs-target="#table-<%= tableId %>">
                    <span>Table #<%= tableId %> Capacity: <%= cap %></span>
                    <span><%= status %></span>
                </div>
                <div id="table-<%= tableId %>" class="collapse card-body">
                    <form method="post" action="updateTable.jsp">
                        <input type="hidden" name="table_id" value="<%= tableId %>" />
                        <div class="mb-2">
                            <label class="form-label">Assign Staff:</label>
                            <select name="new_staff_id" class="form-select" <%= ("Occupied".equalsIgnoreCase(status) || "Reserved".equalsIgnoreCase(status)) ? "disabled" : "" %>>
                                <option value=""></option>
<% for (Map.Entry<Integer,String> e : staffMap.entrySet()) {
       String sel = (staffId != null && e.getKey().equals(staffId)) ? "selected" : "";
%>
                                <option value="<%= e.getKey() %>" <%= sel %>><%= e.getValue() %></option>
<% } %>
                            </select>
                            <% if (!"n/a".equals(assignedAgo)) { %>
                            <div class="text-muted small">Assigned: <%= assignedAgo %></div>
                            <% } %>
                        </div>

                        <div class="mb-2">
                            <label class="form-label">Status:</label>
                            <select name="new_status" class="form-select" <%= ("Occupied".equalsIgnoreCase(status) || "Reserved".equalsIgnoreCase(status)) ? "disabled" : "" %>>
<% for (String s : new String[] {"Available","Occupied","Reserved"}) {
       if (!s.equalsIgnoreCase(status)) {
%>
                                <option value="<%= s %>"><%= s %></option>
<%    } 
   } %>
                            </select>
                        </div>

<% if ("Available".equalsIgnoreCase(status)) { %>
                        <div class="mb-2">
                            <label class="form-label">Customer Name:</label>
                            <input type="text" name="customer_name" class="form-control" list="customerList">
                            <datalist id="customerList">
<% for (String name : customerMap.values()) { %>
                                <option value="<%= name %>">
<% } %>
                            </datalist>
                        </div>
<% } else if (!customerName.isEmpty()) { %>
                        <div class="mb-2">
                            <label class="form-label">Customer:</label>
                            <input type="text" class="form-control" value="<%= customerName %>" disabled>
                            <input type="hidden" name="customer_name" value="<%= customerName %>">
                        </div>
<% } %>

                        <div class="d-flex justify-content-between">
<% if ("Available".equalsIgnoreCase(status)) { %>
                            <button type="submit" class="btn btn-primary">Confirm</button>
<% } %>
                    </form>

                    <form method="post" action="updateTable.jsp">
                        <input type="hidden" name="clear" value="<%= tableId %>" />
                        <button type="submit" class="btn btn-sm btn-danger">Clear Table</button>
                    </form>
                        </div>
                </div>
            </div>
<%
    }
    rs.close();
    stmt.close();
    con.close();
%>
        </div>
    </div>
</body>
</html>
