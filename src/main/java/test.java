import java.sql.*;

public class test {
    public static void main(String[] args) {


        try 
        {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/Nguyen?useSSL=false&serverTimezone=UTC",
                "root", "Password12!"
            );

            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM student");

            while (rs.next()) 
            {
                System.out.println(rs.getInt(1) + " " + rs.getString(2) + " " + rs.getString(3));
            }

            con.close();
            
        } 
        
        catch (Exception e) 
        {
            e.printStackTrace();
        }
    }
}