import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/add-to-cart")
public class OrderServlet extends HttpServlet {
    private static final String JDBC_URL =
        "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "!"; // replace with your actual password

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String customerId = request.getParameter("customer_id");
        String tableId = request.getParameter("table_id");
        String status = request.getParameter("status");
        String mealId = request.getParameter("meal_id");
        String quantity = request.getParameter("quantity");

        // Initialize cart if not present
        List<Map<String, String>> cart = (List<Map<String, String>>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        // Add item to cart if mealId and quantity provided
        if (mealId != null && quantity != null && !mealId.isEmpty() && !quantity.isEmpty()) {
            Map<String, String> item = new HashMap<>();
            item.put("meal_id", mealId);
            item.put("quantity", quantity);
            cart.add(item);
            response.sendRedirect("order.jsp"); // return to form page
            return;
        }

        // Submit full order
        if (request.getParameter("submit_order") != null &&
            customerId != null && tableId != null && status != null) {

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {
                    // Insert order
                    String insertOrderSQL = "INSERT INTO `Order` (customer_id, table_id, status) VALUES (?, ?, ?)";
                    PreparedStatement psOrder = con.prepareStatement(insertOrderSQL, Statement.RETURN_GENERATED_KEYS);
                    psOrder.setInt(1, Integer.parseInt(customerId));
                    psOrder.setInt(2, Integer.parseInt(tableId));
                    psOrder.setString(3, status);
                    psOrder.executeUpdate();

                    ResultSet rs = psOrder.getGeneratedKeys();
                    int orderId = 0;
                    if (rs.next()) {
                        orderId = rs.getInt(1);
                    }

                    // Insert items
                    String insertItemSQL = "INSERT INTO OrderItem (order_id, meal_id, quantity) VALUES (?, ?, ?)";
                    PreparedStatement psItem = con.prepareStatement(insertItemSQL);
                    for (Map<String, String> item : cart) {
                        psItem.setInt(1, orderId);
                        psItem.setInt(2, Integer.parseInt(item.get("meal_id")));
                        psItem.setInt(3, Integer.parseInt(item.get("quantity")));
                        psItem.executeUpdate();
                    }

                    cart.clear();
                    session.setAttribute("message", "Order placed successfully!");
                    response.sendRedirect("order.jsp");

                }
            } catch (Exception e) {
                request.setAttribute("error", "Error: " + e.getMessage());
                request.getRequestDispatcher("order.jsp").forward(request, response);
            }
        }
    }
}
