package com.network.web;

import com.network.core.MessageDAO;
import com.network.model.Message;
import com.network.model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/messages")
public class MessageServlet extends HttpServlet {
    private final MessageDAO messageDAO = new MessageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.setStatus(401);
            return;
        }

        String target = request.getParameter("target");
        if (target == null) return;

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        List<Message> messages;
        if ("ALL".equals(target)) {
            messages = messageDAO.getGroupMessages(0); // 0 or null for global
        } else {
            // Get user ID of target
            int targetId = Integer.parseInt(request.getParameter("targetId"));
            messages = messageDAO.getPrivateMessages(currentUser.getId(), targetId);
        }

        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < messages.size(); i++) {
            Message m = messages.get(i);
            sb.append(String.format("{\"senderName\":\"%s\", \"content\":\"%s\", \"time\":\"%s\", \"isMe\":%b, \"isRead\":%b, \"type\":\"%s\"}", 
                    m.getSenderName(), m.getContent().replace("\"", "\\\"").replace("\n", "\\n"), 
                    m.getSentAt().toString().substring(11, 16),
                    m.getSenderId() == currentUser.getId(),
                    m.isRead(),
                    m.getType()));
            if (i < messages.size() - 1) sb.append(",");
        }
        sb.append("]");
        response.getWriter().write(sb.toString());
    }
}
