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
/*
cd ~/Code\ Project/byte2bite/main

javac \
  -cp "src/main/webapp/WEB-INF/lib/*" \
  -d src/main/webapp/WEB-INF/classes \
  src/main/java/LoginServlet.java

 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final String JDBC_URL =
        "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";  // adjust to your own path
    private static final String DB_USER     = "root";
    private static final String DB_PASSWORD = "!"; //add your password

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String pin      = request.getParameter("pin");
        String lastName = request.getParameter("last_name");

        if (pin == null || lastName == null) {
            request.setAttribute("error", "PIN and Last Name are required.");
            request.getRequestDispatcher("index.jsp")
                   .forward(request, response);
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection con = DriverManager.getConnection(
                     JDBC_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT first_name, last_name, Role " +
                     "FROM Login WHERE Pin = ? AND last_name = ?"
                 )) {

                ps.setString(1, pin);
                ps.setString(2, lastName);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        HttpSession session = request.getSession();
                        session.setAttribute("FirstName", rs.getString("first_name"));
                        session.setAttribute("LastName",  rs.getString("last_name"));
                        session.setAttribute("role",      rs.getString("Role"));

                        String role = rs.getString("Role");
                        if ("Admin".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/admin.jsp");
                        } else if ("manager".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/manager.jsp");
                        } else if ("waitStaff".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/waitStaff.jsp");
                        } else if ("wait_kitchen".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/waitKitchen.jsp");
                        } else {
                            request.setAttribute("error", "Unknown role.");
                            request.getRequestDispatcher("index.jsp")
                                   .forward(request, response);
                        }
                    } else {
                        request.setAttribute("error", "Invalid PIN or last name.");
                        request.getRequestDispatcher("index.jsp")
                               .forward(request, response);
                    }
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("index.jsp")
                   .forward(request, response);
        }
    }
}
