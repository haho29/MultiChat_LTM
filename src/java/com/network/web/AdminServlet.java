package com.network.web;

import com.network.core.ReportDAO;
import com.network.core.UserDAO;
import com.network.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action != null) {
            int targetId = Integer.parseInt(request.getParameter("id"));
            if ("lock".equals(action)) {
                userDAO.updateStatus(targetId, "BANNED");
            } else if ("unlock".equals(action)) {
                userDAO.updateStatus(targetId, "ACTIVE");
                // Also clear temporary ban
                userDAO.banUser(targetId, -999999); 
            } else if ("ban".equals(action)) {
                int minutes = Integer.parseInt(request.getParameter("minutes"));
                userDAO.banUser(targetId, minutes);
            } else if ("delete".equals(action)) {
                userDAO.deleteUser(targetId);
            } else if ("resolve_report".equals(action)) {
                reportDAO.updateReportStatus(targetId, "RESOLVED");
            }
        }

        request.setAttribute("users", userDAO.getAllUsers());
        request.setAttribute("reports", reportDAO.getAllReports());
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }
}
