<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Table Availability</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">
    <div class="text-center mb-4">
        <h2>Table Availability</h2>
    </div>


    <!-- Filter Form -->
    <form method="get" class="row g-3 mb-4 justify-content-center">
        <div class="col-auto">
            <input type="number" name="capacity_filter" class="form-control" placeholder="# of Guests"
                   value="<%= request.getParameter("capacity_filter") != null ? request.getParameter("capacity_filter") : "" %>">
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
    // DB config
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASSWORD = "Anderson!!22";

    String capacityFilter = request.getParameter("capacity_filter");
    String statusFilter = request.getParameter("status_filter");

    int guests = -1;
    if (capacityFilter != null && !capacityFilter.isEmpty()) {
        try { guests = Integer.parseInt(capacityFilter); } catch (NumberFormatException ignored) {}
    }

    // *** ADDED: correct maps ***
    Map<Integer, String> staffMap = new LinkedHashMap<>();
    Map<String, String> customerNameByPhone = new HashMap<>(); // phone -> name

    // Build filtered query using customer_phone (schema change)
    StringBuilder baseSql = new StringBuilder(
        "SELECT table_id, capacity, status, table_staff_id, staff_assigned_time, customer_phone " + // *** CHANGED ***
        "FROM tablechart WHERE 1=1"
    );
    List<Object> params = new ArrayList<>();
    if (statusFilter != null && !statusFilter.isEmpty()) {
        baseSql.append(" AND status = ?");
        params.add(statusFilter);
    }
    if (guests > 0) {
        baseSql.append(" AND capacity >= ?");
        params.add(guests);
    }
    baseSql.append(" ORDER BY status ASC, capacity ASC");

    boolean anyRows = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
        out.println("<div class='alert alert-danger'>JDBC driver not found: " + e.getMessage() + "</div>");
    }

    try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {

        // Load wait staff (unchanged)
        String staffSql = "SELECT s.staff_id, s.first_name, s.last_name " +
                         "FROM Staff s JOIN staff_role r ON s.staff_id = r.staff_id " +
                         "WHERE r.role_name = 'Wait Staff' ORDER BY s.last_name, s.first_name";
        try (PreparedStatement psStaff = con.prepareStatement(staffSql);
             ResultSet staffRs = psStaff.executeQuery()) {
            while (staffRs.next()) {
                int id = staffRs.getInt("staff_id");
                String name = staffRs.getString("first_name") + " " + staffRs.getString("last_name");
                staffMap.put(id, name);
            }
        }

        // *** ADDED: load customer names keyed by phone (no customer_id now) ***
        try (PreparedStatement psCust = con.prepareStatement("SELECT phone, name FROM Customer");
             ResultSet custRs = psCust.executeQuery()) {
            while (custRs.next()) {
                String phone = custRs.getString("phone");
                String name = custRs.getString("name");
                customerNameByPhone.put(phone, name);
            }
        }

        // Execute main filtered query
        try (PreparedStatement ps = con.prepareStatement(baseSql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    anyRows = true;
                    int tableId = rs.getInt("table_id");
                    int cap = rs.getInt("capacity");
                    int staffIdRaw = rs.getInt("table_staff_id");
                    Integer staffId = (!rs.wasNull()) ? staffIdRaw : null;
                    String status = rs.getString("status");

                    // *** CHANGED: use customer_phone instead of customer_id ***
                    String customerPhone = rs.getString("customer_phone");
                    String customerName = (customerPhone != null) ? customerNameByPhone.getOrDefault(customerPhone, "") : "";

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
                    <form method="post" action="updateTable.jsp" class="mb-2">
                        <input type="hidden" name="table_id" value="<%= tableId %>" />
                        <div class="row">
                            <div class="col-md-4 mb-2">
                                <label class="form-label">Assign Staff:</label>
                                <select name="new_staff_id" class="form-select" <%= ("Occupied".equalsIgnoreCase(status) || "Reserved".equalsIgnoreCase(status)) ? "disabled" : "" %>>
                                    <option value=""></option>
        <% for (Map.Entry<Integer,String> e : staffMap.entrySet()) {
               String sel = (staffId != null && e.getKey().equals(staffId)) ? "selected" : "";
        %>
                                    <option value="<%= e.getKey() %>" <%= sel %>><%= e.getValue() %></option>
        <% } %>
                                </select>
                            </div>
                            <div class="col-md-4 mb-2">
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
                        </div>

                        <!-- Customer block: phone is primary key -->
        <% if ("Available".equalsIgnoreCase(status)) { %>
                        <div class="row mb-2">
                            <div class="col-md-6">
                                <label class="form-label">Customer Name:</label>
                                <input type="text" name="customer_name" class="form-control" list="customerList" value="">
                                <datalist id="customerList">
        <% for (String name : customerNameByPhone.values()) { %>
                                    <option value="<%= name %>">
        <% } %>
                                </datalist>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Customer Phone:</label>
                                <input type="text" name="customer_phone" class="form-control" placeholder="e.g., 555-123-4567" value="">
                            </div>
                        </div>
        <% } else if (customerPhone != null && !customerName.isEmpty()) { %>
                        <div class="row mb-2">
                            <div class="col-md-6">
                                <label class="form-label">Customer:</label>
                                <input type="text" class="form-control" value="<%= customerName %>" disabled>
                                <input type="hidden" name="customer_name" value="<%= customerName %>">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone:</label>
                                <input type="text" class="form-control" value="<%= customerPhone %>" disabled>
                                <input type="hidden" name="customer_phone" value="<%= customerPhone %>">
                            </div>
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
                } // end while
            } // end resultset
        } // end prepared statement

        if (!anyRows) {
%>
        <div class="alert alert-info">No tables match the current filters.</div>
<%
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Database error: " + e.getMessage() + "<br>Query: " + baseSql + "</div>");
    }
%>
</body>
</html>
