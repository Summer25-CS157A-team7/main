<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionIdStr = request.getParameter("session_id");
    String[] mealIds    = request.getParameterValues("meal_ids");

    if (mealIds == null || mealIds.length == 0) {
        response.sendRedirect("waitStaff.jsp");
        return;
        }

    int sessionId = Integer.parseInt(sessionIdStr);


    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    String DB_USER     = "root";
    String DB_PASSWORD = "Password12!";

    Connection con                     = null;
    PreparedStatement createTicketStmt = null;
    PreparedStatement insertOrderStmt  = null;
    ResultSet rsKeys                   = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
        con.setAutoCommit(false);

        createTicketStmt = con.prepareStatement(
            "INSERT INTO tickets (session_id, status, placed_at) VALUES (?, 'Placed', NOW())",
            Statement.RETURN_GENERATED_KEYS
        );
        createTicketStmt.setInt(1, sessionId);
        int count = createTicketStmt.executeUpdate();  



        rsKeys = createTicketStmt.getGeneratedKeys();
        if (rsKeys == null || !rsKeys.next()) 
        {     
            throw new SQLException("No ticket_id returned.");
        }
        int ticketId = rsKeys.getInt(1);
        rsKeys.close();
        createTicketStmt.close();


        insertOrderStmt = con.prepareStatement( "INSERT INTO orders (ticket_id, meal_id) VALUES (?, ?)" );
        for (String mid : mealIds) 
        {
            int mealId = Integer.parseInt(mid);
            insertOrderStmt.setInt(1, ticketId);
            insertOrderStmt.setInt(2, mealId);
            insertOrderStmt.addBatch();
        }
        insertOrderStmt.executeBatch();
        insertOrderStmt.close();

        con.commit();

        response.sendRedirect("waitStaff.jsp");
    } catch (Exception e) 
    {
        out.println("Error submitting order: " + e.getMessage() );
    }
%>
    