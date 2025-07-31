<%@ page import="java.sql.*" %>
<%
    String[] tableIds    = request.getParameterValues("table_id");
    String[] newStaffIds = request.getParameterValues("new_staff_id");
    String[] newStatuses = request.getParameterValues("new_status");


    int updateAmount = Math.min(tableIds.length, Math.min(newStaffIds.length, newStatuses.length));

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
                "root", "Password12!")) {

            String sql = "UPDATE tablechart SET status = ?, table_staff_id = ? WHERE table_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                for (int i = 0; i < updateAmount; i++) {
                    int tableId = Integer.parseInt(tableIds[i]);
                    int staffId = Integer.parseInt(newStaffIds[i]);
                    String status = newStatuses[i];

                    ps.setString(1, status);
                    ps.setInt(2, staffId);
                    ps.setInt(3, tableId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
        }

        response.sendRedirect("viewTables.jsp");
    } catch (Exception e) {
        out.println("<p style='color:red;'>Update failed: " + e.getMessage() + "</p>");
    }
%>
