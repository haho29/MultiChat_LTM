package com.network.web;

import com.network.core.FriendDAO;
import com.network.core.GroupDAO;
import com.network.core.MessageDAO;
import com.network.core.ReportDAO;
import com.network.core.UserDAO;
import com.network.core.DBContext;
import com.network.model.User;
import java.io.IOException;
import java.sql.*;
import java.util.*;
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
    private final MessageDAO messageDAO = new MessageDAO();
    private final GroupDAO groupDAO = new GroupDAO();

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
                    User targetUser = userDAO.getUserById(targetId);
                    if (targetUser != null) ChatWebSocketServer.sendSignal(targetUser.getUsername(), "SYSTEM_LOCK");
                    String reportId = request.getParameter("reportId");
                    if (reportId != null) reportDAO.updateReportStatus(Integer.parseInt(reportId), "RESOLVED");
                } else if ("unlock".equals(action)) {
                    userDAO.updateStatus(targetId, "ACTIVE");
                    userDAO.banUser(targetId, -999999); 
                } else if ("ban".equals(action)) {
                    int minutes = Integer.parseInt(request.getParameter("minutes"));
                    userDAO.banUser(targetId, minutes);
                    String reportId = request.getParameter("reportId");
                    if (reportId != null) reportDAO.updateReportStatus(Integer.parseInt(reportId), "RESOLVED");
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
            } else if ("delete_message".equals(action)) {
                int msgId = Integer.parseInt(request.getParameter("msgId"));
                messageDAO.deleteMessage(msgId);
                // If it came from a report, maybe resolve it too
                String reportId = request.getParameter("reportId");
                if (reportId != null) reportDAO.updateReportStatus(Integer.parseInt(reportId), "RESOLVED");
            } else if ("delete_group".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                groupDAO.deleteGroup(groupId);
            } else if ("remove_member".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                int userId = Integer.parseInt(request.getParameter("userId"));
                groupDAO.removeMember(groupId, userId);
            } else if ("add_member".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                String username = request.getParameter("username");
                User target = userDAO.getUserByUsername(username);
                if (target != null) groupDAO.addMember(groupId, target.getId());
            } else if ("broadcast".equals(action)) {
                String msg = request.getParameter("message");
                ChatWebSocketServer.broadcast("SYSTEM|" + msg);
            } else if ("get_members".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                List<User> members = groupDAO.getGroupMembers(groupId);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < members.size(); i++) {
                    User u = members.get(i);
                    sb.append("{\"id\":").append(u.getId()).append(",\"username\":\"").append(u.getUsername()).append("\",\"fullName\":\"").append(u.getFullName()).append("\"}");
                    if (i < members.size() - 1) sb.append(",");
                }
                sb.append("]");
                response.getWriter().write(sb.toString());
                return;
            }
        }

        String query = request.getParameter("search");
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isEmpty()) statusFilter = "ALL";
        
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("users", userDAO.searchUsersWithFilter(query, statusFilter));
        request.setAttribute("reports", reportDAO.getAllReports());
        request.setAttribute("friendships", friendDAO.getAllFriendships());
        request.setAttribute("groups", groupDAO.getAllGroups());
        request.setAttribute("media", messageDAO.getMediaMessages());
        
        // Stats
        request.setAttribute("stats", getStats());
        
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }

    private java.util.Map<String, Object> getStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        try (Connection conn = DBContext.getConnection()) {
            // Total Users
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) stats.put("totalUsers", rs.getInt(1));
            }
            // Online Users
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE is_online = 1")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) stats.put("onlineUsers", rs.getInt(1));
            }
            // Messages Today
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM messages WHERE CAST(sent_at AS DATE) = CAST(GETDATE() AS DATE)")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) stats.put("messagesToday", rs.getInt(1));
            }
            // Pending Reports
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM reports WHERE status = 'PENDING'")) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) stats.put("pendingReports", rs.getInt(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }
}
