<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>JDBC Connect</title>
</head>
<body>

<%

	try {
		java.sql.Connection con;
		Class.forName("com.mysql.cj.jdbc.Driver");
		con = DriverManager.getConnection("jdbc:mysql://localhost:3306/Nguyen?autoReconnect=true&useSSL=false",
				"root",
				"Password12!");
		
		Statement stmt=con.createStatement();
		ResultSet rs=stmt.executeQuery("SELECT * FROM student");
		
		while (rs.next()) {
            out.println("<br>" + rs.getInt(1) + " " + rs.getString(2) + " " + rs.getString(3));
        }

        con.close();
        
	}
	
	catch(SQLException e) {
    out.println("SQLException caught: " + e.getMessage());
}

%>
</body>
</html>