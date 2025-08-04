<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Kitchen Hub</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/employeeHub.css?v=<%= System.currentTimeMillis() %>" />
</head>
<body class="container mt-5">

    <%
        String firstName = (String) session.getAttribute("FirstName");
        String lastName = (String) session.getAttribute("LastName");
        String role = (String) session.getAttribute("role");
    %>
    <div class="top-right">
    <div class="user-info">
        <%= role %> : <%= firstName %> <%= lastName %>
    </div>
    <div class="user-icon">
        <a href="timeTracking.jsp">
        <img src="<%= request.getContextPath() %>/images/clock.png" alt="Clock" />
        </a>
    </div>
    </div>

    <div class="row justify-content-center">
        <div class="col-md-8 text-center">
            <h2 class="mb-4">Chef Hub</h2>

            <!-- Modify Orders -->
            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Modify Active Orders</h5>
                    <p class="card-text mb-3">- Update order status: Preparing, Ready, Complete.</p>
                    <a href="KitchenStaff.jsp" class="btn btn-primary btn-sm">Manage Orders</a>
                </div>
            </div>

            <!-- View Ingredient Usage -->
            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">View Ingredient Usage</h5>
                    <p class="card-text mb-3">- Check ingredients used in current active orders for preparation.</p>
                    <a href="InventoryTracker.jsp" class="btn btn-primary btn-sm">View Usage</a>
                </div>
            </div>

            <!-- Low Stock Alerts -->
            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2"> Food Stock</h5>
                    <p class="card-text mb-3">- List of inventory items below stock threshold.</p>
                    <a href="lowStockPanel.jsp" class="btn btn-primary btn-sm">View Alerts</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
