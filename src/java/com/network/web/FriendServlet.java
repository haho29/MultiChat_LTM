package com.network.web;

import com.network.core.FriendDAO;
import com.network.core.UserDAO;
import com.network.model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/friend")
public class FriendServlet extends HttpServlet {
    private final FriendDAO friendDAO = new FriendDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.setStatus(401);
            return;
        }

        String type = request.getParameter("type");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if ("list".equals(type)) {
            List<User> friends = friendDAO.getFriendsList(currentUser.getId());
            // Loại bỏ chính mình một lần nữa để chắc chắn
            friends.removeIf(u -> u.getId() == currentUser.getId());
            response.getWriter().write(toJson(friends));
        } else if ("pending".equals(type)) {
            List<User> pending = friendDAO.getPendingRequests(currentUser.getId());
            response.getWriter().write(toJson(pending));
        } else if ("sent".equals(type)) {
            List<User> sent = friendDAO.getSentRequests(currentUser.getId());
            response.getWriter().write(toJson(sent));
        } else if ("search".equals(type)) {
            String query = request.getParameter("query");
            User user = userDAO.searchUser(query);
            // Không hiển thị chính mình khi tìm kiếm
            if (user != null && user.getId() != currentUser.getId()) {
                response.getWriter().write("{\"id\":" + user.getId() + ",\"username\":\"" + user.getUsername() + "\",\"fullName\":\"" + user.getFullName() + "\"}");
            } else {
                response.getWriter().write("null");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.setStatus(401);
            return;
        }

        String action = request.getParameter("action");
        String username = request.getParameter("username");
        System.out.println("DEBUG: Action=" + action + ", Username Query=" + username);
        
        String query = (username != null) ? username.trim() : "";
        User targetUser = userDAO.searchUser(query);

        if (targetUser == null) {
            System.out.println("DEBUG: User NOT FOUND for query: " + query);
            response.getWriter().write("Không tìm thấy người dùng này");
            return;
        }
        System.out.println("DEBUG: User FOUND: " + targetUser.getUsername() + " (ID: " + targetUser.getId() + ")");

        boolean success = false;
        if ("add".equals(action)) {
            if (currentUser.getId() == targetUser.getId()) {
                response.getWriter().write("You cannot add yourself");
                return;
            }
            success = friendDAO.sendFriendRequest(currentUser.getId(), targetUser.getId());
            if (success) {
                ChatWebSocketServer.sendFriendSignal(targetUser.getUsername());
            }
            response.getWriter().write(success ? "Request sent" : "Request already exists");
        } else if ("accept".equals(action)) {
            success = friendDAO.updateFriendStatus(targetUser.getId(), currentUser.getId(), "ACCEPTED");
            if (success) {
                ChatWebSocketServer.sendFriendSignal(targetUser.getUsername());
            }
            response.getWriter().write(success ? "Accepted" : "Failed");
        } else if ("reject".equals(action)) {
            success = friendDAO.updateFriendStatus(targetUser.getId(), currentUser.getId(), "REJECTED");
            if (success) {
                ChatWebSocketServer.sendFriendSignal(targetUser.getUsername());
            }
            response.getWriter().write(success ? "Rejected" : "Failed");
        } else if ("cancel".equals(action)) {
            success = friendDAO.updateFriendStatus(currentUser.getId(), targetUser.getId(), "REJECTED");
            if (success) {
                ChatWebSocketServer.sendFriendSignal(targetUser.getUsername());
            }
            response.getWriter().write(success ? "Cancelled" : "Failed");
        }
    }

    private String toJson(List<User> users) {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (int i = 0; i < users.size(); i++) {
            User u = users.get(i);
            sb.append("{");
            sb.append("\"id\":").append(u.getId()).append(",");
            sb.append("\"username\":\"").append(u.getUsername()).append("\",");
            sb.append("\"fullName\":\"").append(u.getFullName()).append("\",");
            sb.append("\"isOnline\":").append(u.isOnline());
            sb.append("}");
            if (i < users.size() - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }
}
