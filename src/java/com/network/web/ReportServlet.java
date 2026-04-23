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

@WebServlet("/report")
public class ReportServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.setStatus(401);
            return;
        }

        User dbUser = userDAO.getUserById(currentUser.getId());
        if (dbUser != null && "BANNED".equals(dbUser.getStatus())) {
            response.setStatus(403);
            return;
        }

        String reportedUsername = request.getParameter("reportedUsername");
        String content = request.getParameter("content");
        String reason = request.getParameter("reason");
        String messageIdStr = request.getParameter("messageId");
        Integer messageId = (messageIdStr != null && !messageIdStr.isEmpty()) ? Integer.parseInt(messageIdStr) : null;

        User reportedUser = userDAO.getUserByUsername(reportedUsername);
        if (reportedUser != null) {
            boolean success = reportDAO.saveReport(currentUser.getId(), reportedUser.getId(), reason, content, messageId);
            response.getWriter().write(success ? "Report sent" : "Error sending report");
        } else {
            response.getWriter().write("User not found");
        }
    }
}
