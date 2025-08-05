<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%!
    // helper to format elapsed time
    String formatElapsed(Timestamp ts) {
        if (ts == null) return "N/A";
        Instant created = ts.toInstant();
        Duration diff = Duration.between(created, Instant.now());
        long totalMinutes = diff.toMinutes();
        long hours = totalMinutes / 60;
        long minutes = totalMinutes % 60;
        if (hours > 0) return hours + "h " + minutes + "m ago";
        return minutes + "m ago";
    }
%>

<%
    String DB_USER = "root";
    String DB_PASSWORD = "Password12!";
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String updateTicketId = request.getParameter("update_ticket_id");
        String newStatus = request.getParameter("new_status");
        if (updateTicketId != null && newStatus != null) {
            try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement("UPDATE tickets SET status=? WHERE ticket_id=?")) {
                ps.setString(1, newStatus);
                ps.setInt(2, Integer.parseInt(updateTicketId));
                ps.executeUpdate();


                if ("Ready".equalsIgnoreCase(newStatus)) {
                    try (PreparedStatement psDeduct = conn.prepareStatement(
                        "UPDATE Food_Inventory fi " +
                        "JOIN made_with mw    ON fi.item_name = mw.item_name " +
                        "JOIN orders o        ON o.meal_id    = mw.meal_id " +
                        "SET fi.quantity = fi.quantity - mw.quantity " +
                        "WHERE o.ticket_id = ?"
                    )) {
                        psDeduct.setInt(1, Integer.parseInt(updateTicketId));
                        psDeduct.executeUpdate();
                    }
                }

                response.sendRedirect("KitchenStaff.jsp");
                return;
            } catch (Exception e) {
                out.println("Error updating status: " + e.getMessage());
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Kitchen Tickets</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container my-5">
    <h2 class="mb-4">Kitchen Dashboard</h2>

    <h3 class="mt-4">Active Tickets</h3>
<%
    String activeSql =
        "SELECT t.ticket_id, t.status AS ticket_status, t.placed_at, o.meal_id, o.note, m.name AS meal_name " +
        "FROM tickets t " +
        "JOIN orders o ON o.ticket_id = t.ticket_id " +
        "JOIN meal m ON o.meal_id = m.meal_id " +
        "WHERE t.status <> 'Ready'AND t.status <> 'Completed' " +
        "ORDER BY t.placed_at DESC, t.ticket_id";

    try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
         PreparedStatement ps = conn.prepareStatement(activeSql);
         ResultSet rs = ps.executeQuery()) {

        long lastTicketId = -1;
        boolean anyActive = false;

        while (rs.next()) {
            anyActive = true;
            int ticketId = rs.getInt("ticket_id");
            String ticketStatus = rs.getString("ticket_status");
            Timestamp placedAt = rs.getTimestamp("placed_at");
            String mealName = rs.getString("meal_name");
            String note = rs.getString("note");

            String elapsed = formatElapsed(placedAt);

            if (ticketId != lastTicketId) {
                if (lastTicketId != -1) {
%>
        </div>
    </div>
<%
                }
%>
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <div>
                <strong>Ticket #<%= ticketId %></strong>
                <div class="small text-muted">Placed: <%= elapsed %></div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <%-- badge only if not "Placed" --%>
                <% if (!"Placed".equalsIgnoreCase(ticketStatus)) { %>
                    <span class="badge 
                        <% if ("Ready".equalsIgnoreCase(ticketStatus)) { %>bg-success<% } else if ("Preparing".equalsIgnoreCase(ticketStatus)) { %>bg-warning text-dark<% } else { %>bg-info text-dark<% } %>">
                        <%= ticketStatus %>
                    </span>
                <% } %>

                <% if (!"Preparing".equalsIgnoreCase(ticketStatus)) { %>
                <form method="post" class="d-inline">
                    <input type="hidden" name="update_ticket_id" value="<%= ticketId %>">
                    <input type="hidden" name="new_status" value="Preparing">
                    <button class="btn btn-sm btn-warning" type="submit">Preparing</button>
                </form>
                <% } %>

                <% if (!"Ready".equalsIgnoreCase(ticketStatus)) { %>
                <form method="post" class="d-inline ms-1">
                    <input type="hidden" name="update_ticket_id" value="<%= ticketId %>">
                    <input type="hidden" name="new_status" value="Ready">
                    <button class="btn btn-sm btn-success" type="submit">Ready</button>
                </form>
                <% } %>
            </div>
        </div>
        <div class="card-body">
<%
                lastTicketId = ticketId;
            }
%>
            <div class="mb-2">
                <div><strong><%= mealName %></strong> <% if (note != null && !note.isBlank()) { %><em>(<%= note %>)</em><% } %></div>
            </div>
<%
        }

        if (anyActive) {
%>
        </div>
    </div>
<%
        } else {
%>
    <p>No active tickets.</p>
<%
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading active tickets: " + e.getMessage() + "</div>");
    }
%>

    <h3 class="mt-5">Ready Tickets</h3>
<%
    String readySql =
        "SELECT t.ticket_id, t.status AS ticket_status, t.placed_at, o.meal_id, o.note, m.name AS meal_name " +
        "FROM tickets t " +
        "JOIN orders o ON o.ticket_id = t.ticket_id " +
        "JOIN meal m ON o.meal_id = m.meal_id " +
        "WHERE t.status = 'Ready' AND t.status <> 'Completed' " +
        "ORDER BY t.placed_at ASC, t.ticket_id";

    try (Connection conn2 = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
         PreparedStatement psReady = conn2.prepareStatement(readySql);
         ResultSet rsReady = psReady.executeQuery()) {

        long lastTicketId = -1;
        boolean anyReady = false;

        while (rsReady.next()) {
            anyReady = true;
            int ticketId = rsReady.getInt("ticket_id");
            String ticketStatus = rsReady.getString("ticket_status");
            Timestamp placedAt = rsReady.getTimestamp("placed_at");
            String mealName = rsReady.getString("meal_name");
            String note = rsReady.getString("note");

            String elapsed = formatElapsed(placedAt);

            if (ticketId != lastTicketId) {
                if (lastTicketId != -1) {
%>
        </div>
    </div>
<%
                }
%>
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <div>
                <strong>Ticket #<%= ticketId %></strong>
                <div class="small text-muted">Placed: <%= elapsed %></div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge bg-success"><%= ticketStatus %></span>
                <% if (!"Preparing".equalsIgnoreCase(ticketStatus)) { %>
                <form method="post" class="d-inline">
                    <input type="hidden" name="update_ticket_id" value="<%= ticketId %>">
                    <input type="hidden" name="new_status" value="Preparing">
                    <button class="btn btn-sm btn-warning" type="submit">Preparing</button>
                </form>
                <% } %>
            </div>
        </div>
        <div class="card-body">
<%
                lastTicketId = ticketId;
            }
%>
            <div class="mb-2">
                <div><strong><%= mealName %></strong> <% if (note != null && !note.isBlank()) { %><em>(<%= note %>)</em><% } %></div>
            </div>
<%
        }

        if (anyReady) {
%>
        </div>
    </div>
<%
        } else {
%>
    <p>No ready tickets.</p>
<%
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading ready tickets: " + e.getMessage() + "</div>");
    }
%>

</body>
</html>
