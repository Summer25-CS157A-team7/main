<%@ page import="java.sql.*" %>
<%
    String clearFlag = request.getParameter("clear");
    String[] tableIds    = request.getParameterValues("table_id");
    String[] newStaffIds = request.getParameterValues("new_staff_id");
    String[] newStatuses = request.getParameterValues("new_status");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&zeroDateTimeBehavior=CONVERT_TO_NULL&serverTimezone=UTC",
                "root", "Password12!")) {

            if (clearFlag != null && !clearFlag.isBlank()) 
            {
                int tableId = Integer.parseInt(clearFlag);
                String sql = "UPDATE tablechart SET table_staff_id = NULL, status = 'Available', staff_assigned_time = NULL WHERE table_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) 
                {
                    ps.setInt(1, tableId);
                    ps.executeUpdate();
                }
                response.sendRedirect("viewTables.jsp");
                return;
            } 

            else if (tableIds != null && newStaffIds != null && newStatuses != null) {
                int n = Math.min(tableIds.length, Math.min(newStaffIds.length, newStatuses.length));
                String sql = "UPDATE tablechart SET status = ?, table_staff_id = ?, staff_assigned_time = NOW() WHERE table_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    for (int i = 0; i < n; i++) 
                    {

                        int tid = Integer.parseInt(tableIds[i]);
                        String staffIdStr = newStaffIds[i];
                        String status = newStatuses[i];


                        if (staffIdStr == null || staffIdStr.isBlank()) 
                        {
                            continue;
                        }
                        int newStaff = Integer.parseInt(staffIdStr);

                        ps.setString(1, status);
                        ps.setInt(2, newStaff);
                        ps.setInt(3, tid);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }
        }

        response.sendRedirect("viewTables.jsp");
    } catch (Exception e) {
        out.println("<p style='color:red;'>Update failed: " + e.getMessage() + "</p>");
    }
%>
