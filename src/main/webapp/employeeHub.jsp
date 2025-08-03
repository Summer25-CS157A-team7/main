<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Server Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-8 text-center">
            <h2 class="mb-4">Server Hub</h2>

            <!-- Submit Order -->
            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Submit New Order</h5>
                    <p class="card-text mb-3">- Place a new meal order for a customer's table.</p>
                    <a href="waitStaff.jsp" class="btn btn-primary btn-sm">Submit Order</a>
                </div>
            </div>

            <!-- View Active Orders -->
            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">View Active Orders</h5>
                    <p class="card-text mb-3">- Check the status of current orders assigned to tables.</p>
                    <a href="modifyOrderStatus.jsp" class="btn btn-primary btn-sm">View Active Orders</a>
                </div>
            </div>

            <!-- Dining Overview -->
            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Table Availability</h5>
                    <p class="card-text mb-3">- View Table Availability</p>
                    <a href="viewTables.jsp" class="btn btn-primary btn-sm">Go to Table Dashboard</a>
                </div>
            </div>


            <!-- Clock In/Out -->
            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Clock In / Out</h5>
                    <p class="card-text mb-3">- Log work hours by clocking in, taking breaks, or ending shift.</p>
                    <a href="timeTracking.jsp" class="btn btn-primary btn-sm">Manage Time</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
