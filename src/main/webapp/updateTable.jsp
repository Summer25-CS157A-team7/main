<%@ page import="java.sql.*" %>
<%
    String tableIdStr = request.getParameter("table_id");
    String newStatus = request.getParameter("new_status");

    try {
        int tableId = Integer.parseInt(tableIdStr);

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
            "root", "Anderson!!22"
        );

        PreparedStatement ps = con.prepareStatement(
            "UPDATE tablechart SET status = ? WHERE table_id = ?"
        );
        ps.setString(1, newStatus);
        ps.setInt(2, tableId);

        ps.executeUpdate();
        ps.close();
        con.close();

        response.sendRedirect("viewTables.jsp");
    } catch (Exception e) {
        out.println("<p style='color:red;'>Update failed: " + e.getMessage() + "</p>");
    }
%>
