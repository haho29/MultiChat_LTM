package com.network.web;

import com.network.core.FriendDAO;
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
    private final FriendDAO friendDAO = new FriendDAO();

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
            String idStr = request.getParameter("id");
            if (idStr != null) {
                int targetId = Integer.parseInt(idStr);
                if ("lock".equals(action)) {
                    userDAO.updateStatus(targetId, "BANNED");
                } else if ("unlock".equals(action)) {
                    userDAO.updateStatus(targetId, "ACTIVE");
                    userDAO.banUser(targetId, -999999); 
                } else if ("ban".equals(action)) {
                    int minutes = Integer.parseInt(request.getParameter("minutes"));
                    userDAO.banUser(targetId, minutes);
                } else if ("delete".equals(action)) {
                    userDAO.deleteUser(targetId);
                }
            }
            
            if ("delete_friendship".equals(action)) {
                int u1 = Integer.parseInt(request.getParameter("u1"));
                int u2 = Integer.parseInt(request.getParameter("u2"));
                friendDAO.deleteFriendship(u1, u2);
            } else if ("resolve_report".equals(action)) {
                int reportId = Integer.parseInt(request.getParameter("id"));
                reportDAO.updateReportStatus(reportId, "RESOLVED");
            }
        }

        String query = request.getParameter("search");
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isEmpty()) statusFilter = "ALL";
        
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("users", userDAO.searchUsersWithFilter(query, statusFilter));
        request.setAttribute("reports", reportDAO.getAllReports());
        request.setAttribute("friendships", friendDAO.getAllFriendships());
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }
}
