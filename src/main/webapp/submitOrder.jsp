<%@ page import="java.sql.*" %>
<%
    String tableIdStr = request.getParameter("table_id");
    String[] mealIds = request.getParameterValues("meal_ids");

    if (mealIds == null || mealIds.length == 0) {
        out.println("<p style='color:red;'>Please select at least one meal.</p>");
        return;
    }

    try {
        int tableId = Integer.parseInt(tableIdStr);

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false", "root", "Anderson!!22");

        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO `order` (table_id, meal_id, status) VALUES (?, ?, 'Pending')"
        );

        for (String mealIdStr : mealIds) {
            int mealId = Integer.parseInt(mealIdStr);
            ps.setInt(1, tableId);
            ps.setInt(2, mealId);
            ps.executeUpdate();
        }

        ps.close();
        con.close();

        response.sendRedirect("viewOrders.jsp");
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error submitting order: " + e.getMessage() + "</p>");
    }
%>
