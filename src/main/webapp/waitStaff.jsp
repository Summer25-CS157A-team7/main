<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Order - Add to Cart</title>
</head>
<body>
<h2>Create a New Order</h2>

<% String message = (String) session.getAttribute("message");
   if (message != null) {
       out.println("<p style='color:green;'>" + message + "</p>");
       session.removeAttribute("message");
   }

   String error = (String) request.getAttribute("error");
   if (error != null) {
       out.println("<p style='color:red;'>" + error + "</p>");
   }
%>

<form method="post" action="add-to-cart">
    Customer ID: <input type="text" name="customer_id" required><br><br>
    Table ID: <input type="text" name="table_id" required><br><br>
    Status:
    <select name="status">
        <option value="pending">Pending</option>
        <option value="in_progress">In Progress</option>
        <option value="completed">Completed</option>
    </select><br><br>

    Meal ID: <input type="text" name="meal_id" required>
    Quantity: <input type="number" name="quantity" min="1" required>
    <input type="submit" value="Add to Cart">
</form>

<hr>
<h3>🛒 Current Cart:</h3>
<ul>
<%
    List<Map<String, String>> cart = (List<Map<String, String>>) session.getAttribute("cart");
    if (cart != null && !cart.isEmpty()) {
        for (Map<String, String> item : cart) {
            out.println("<li>Meal ID: " + item.get("meal_id") + ", Quantity: " + item.get("quantity") + "</li>");
        }
    } else {
        out.println("<li>Your cart is empty.</li>");
    }
%>
</ul>

<form method="post" action="add-to-cart">
    <input type="hidden" name="submit_order" value="true">
    <input type="hidden" name="customer_id" value="<%= request.getParameter("customer_id") %>">
    <input type="hidden" name="table_id" value="<%= request.getParameter("table_id") %>">
    <input type="hidden" name="status" value="<%= request.getParameter("status") %>">
    <input type="submit" value="Submit Full Order">
</form>

</body>
</html>
