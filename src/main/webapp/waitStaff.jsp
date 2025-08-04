<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>


<%
    List<String> entrees = new ArrayList<>();
    List<String> sides = new ArrayList<>();
    List<String> desserts = new ArrayList<>();
    List<String> beverages = new ArrayList<>();

    class SessionOption 
    {
        int sessionId;
    }

    PreparedStatement sessStmt = con.prepareStatement("SELECT session_id FROM sessions WHERE (closed_at IS NULL ) ORDER BY session_id DESC");
    ResultSet sessRs = sessStmt.executeQuery();



    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
            "root", "Password12!");

        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT m.meal_id, m.name,m.price, c.name AS categoryNames FROM meal m JOIN category c ON m.category_id = c.category_id ORDER BY c.name, m.name");

        while (rs.next()) {
            int mealId = rs.getInt("meal_id");
            String mealName = rs.getString("name");
            String categoryName = rs.getString("categoryNames");
            double mealPrice = rs.getDouble("price");

                String rowDescription = "<div style='margin-bottom:8px;'>" + "<label><input type='checkbox' name='meal_ids' value='" + mealId + "' /> " + mealName + " ($" + mealPrice + ")</label>" + "</div>";

                switch (categoryName) {
                    case "Entree":
                        entrees.add(rowDescription);
                        break;
                    case "Side":
                        sides.add(rowDescription);
                        break;
                    case "Dessert":
                        desserts.add(rowDescription);
                        break;
                    case "Beverage":
                        beverages.add(rowDescription);
                        break;
                    default:
                        break;
                }
            }
        
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading meals: " + e.getMessage() + "</p>");
    }
%>




<html>
<body>
    <h1>Enter a New Order</h1>

    <form method="post" action="submitOrder.jsp">
        <label>Table Number:</label>
        <input type="number" name="table_id" required /><br/><br/>

    <h2>Entree</h2>
        <table >
            <thead>
            </thead>
            <tbody>
                <% 
                    for (String entreeMeal : entrees) 
                    { 
                        out.println(entreeMeal); 
                    }
                %>
            </tbody>
        </table>

        <h2>Side</h2>
        <table>
            <thead>
            </thead>
            <tbody>
                <% 
                    for (String sideMeal : sides) 
                    { 
                        out.println(sideMeal); 
                    }
                %>
            </tbody>
        </table>


        <h2>Beverage</h2>
        <table>
            <tbody>
                <% 
                    for (String beverageMeal : beverages) 
                    { 
                        out.println(beverageMeal); 
                    }
                %>
            </tbody>
        </table>


        <h2>Dessert</h2>
        <table>
            <tbody>
                <% 
                    for (String dessertMeal : desserts) 
                    { 
                        out.println(dessertMeal); 
                    }
                %>
            </tbody>
        </table>

        <input type="submit" value="Submit Order" />
    </form>
</body>
</html>
