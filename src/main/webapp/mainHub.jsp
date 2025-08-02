<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite - Main Hub</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons (Optional) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="text-center mb-4">
            <h1 class="display-5 fw-bold">🍽️ Byte2Bite Management Hub</h1>
            <p class="lead text-muted">Quick access to key views</p>
        </div>

        <div class="row row-cols-1 row-cols-md-2 g-4">

            <div class="col">
                <a href="viewTables.jsp" class="btn btn-outline-secondary w-100 py-3">
                    <i class="bi bi-table me-2"></i> View Tables
                </a>
            </div>

            <div class="col">
                <a href="orderViewMenu.jsp" class="btn btn-outline-success w-100 py-3">
                    <i class="bi bi-card-list me-2"></i> Order Menu View
                </a>
            </div>

            <div class="col">
                <a href="waitStaff.jsp" class="btn btn-outline-primary w-100 py-3">
                    <i class="bi bi-people-fill me-2"></i> Manage Waitstaff
                </a>
            </div>

        </div>
    </div>

    <!-- Bootstrap JS Bundle (Optional) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
