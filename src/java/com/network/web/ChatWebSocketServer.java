package com.network.web;

import com.network.core.FriendDAO;
import com.network.core.MessageDAO;
import com.network.core.UserDAO;
import com.network.model.Message;
import com.network.model.User;
import java.io.IOException;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

@ServerEndpoint("/chatServer/{username}")
public class ChatWebSocketServer {
    private static final Map<String, Session> clients = new ConcurrentHashMap<>();
    private static final DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
    
    private final UserDAO userDAO = new UserDAO();
    private final MessageDAO messageDAO = new MessageDAO();
    private final FriendDAO friendDAO = new FriendDAO();

    @OnOpen
    public void onOpen(Session session, @PathParam("username") String username) throws IOException {
        if (username == null || username.trim().isEmpty()) return;
        
        String cleanName = username.trim();
        User user = userDAO.getUserByUsername(cleanName);
        
        if (user == null || "BANNED".equals(user.getStatus()) || user.isBanned()) {
            String reason = (user != null && user.isBanned()) ? "Bạn đang bị cấm chat." : "Tài khoản bị khóa hoặc không hợp lệ";
            session.close(new CloseReason(CloseReason.CloseCodes.CANNOT_ACCEPT, reason));
            return;
        }

        clients.put(cleanName, session);
        userDAO.updateOnlineStatus(user.getId(), true);
        
        System.out.println("Kết nối mới: " + cleanName);
        broadcastOnlineStatus(cleanName, true);
    }

    @OnMessage
    public void onMessage(String message, Session session, @PathParam("username") String senderName) throws IOException {
        String currentTime = LocalTime.now().format(timeFormatter);
        User sender = userDAO.getUserByUsername(senderName);
        
        if (sender == null || "BANNED".equals(sender.getStatus())) return;
        if (sender.isBanned()) {
            session.getBasicRemote().sendText("SYSTEM_ERROR:Bạn đang bị cấm chat cho đến " + sender.getBannedUntil().toString().substring(0, 16));
            return;
        }

        if (message.contains("|")) {
            String[] parts = message.split("\\|", 3);
            String target = parts[0].trim();
            String content = parts[1].trim();
            String type = (parts.length > 2) ? parts[2].trim() : "TEXT";

            if (target.equalsIgnoreCase("ALL")) {
                Message msg = new Message();
                msg.setSenderId(sender.getId());
                msg.setContent(content);
                msg.setType(type);
                messageDAO.saveMessage(msg);
                
                broadcast("FROM_ALL:" + senderName + "|" + content + "|" + currentTime + "|" + type);
            } else if (target.startsWith("TYPING_")) {
                // Handle Typing signals: TYPING_START|target or TYPING_STOP|target
                String action = target.split("_")[1]; // START or STOP
                User receiver = userDAO.getUserByUsername(content);
                if (receiver != null) {
                    Session targetSession = clients.get(content);
                    if (targetSession != null && targetSession.isOpen()) {
                        targetSession.getBasicRemote().sendText("TYPING_UPDATE:" + senderName + "|" + action);
                    }
                }
            } else if (target.equals("MARK_READ")) {
                // content is the senderName of the messages being read
                User senderOfMsg = userDAO.getUserByUsername(content);
                if (senderOfMsg != null) {
                    // Update database
                    updateMessageReadStatus(senderOfMsg.getId(), sender.getId());
                    // Notify the sender
                    Session senderSession = clients.get(content);
                    if (senderSession != null && senderSession.isOpen()) {
                        senderSession.getBasicRemote().sendText("READ_UPDATE:" + senderName);
                    }
                }
            } else {
                User receiver = userDAO.getUserByUsername(target);
                if (receiver != null) {
                    if (friendDAO.isFriend(sender.getId(), receiver.getId()) || "ADMIN".equals(sender.getRole())) {
                        Message msg = new Message();
                        msg.setSenderId(sender.getId());
                        msg.setReceiverId(receiver.getId());
                        msg.setContent(content);
                        msg.setType(type);
                        messageDAO.saveMessage(msg);

                        Session targetSession = clients.get(target);
                        if (targetSession != null && targetSession.isOpen()) {
                            targetSession.getBasicRemote().sendText("FROM_PRIVATE:" + senderName + "|" + content + "|" + currentTime + "|" + type);
                        }
                        session.getBasicRemote().sendText("FROM_PRIVATE:" + target + "|" + content + "|" + currentTime + "|" + type + "|IS_ME");
                    } else {
                        session.getBasicRemote().sendText("SYSTEM_ERROR:Bạn chỉ có thể nhắn tin cho bạn bè.");
                    }
                }
            }
        }
    }

    private void updateMessageReadStatus(int senderId, int receiverId) {
        String sql = "UPDATE [messages] SET [is_read] = 1 WHERE [sender_id] = ? AND [receiver_id] = ? AND [is_read] = 0";
        try (java.sql.Connection conn = com.network.core.DBContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @OnClose
    public void onClose(Session session, @PathParam("username") String username) throws IOException {
        if (username != null) {
            String cleanName = username.trim();
            clients.remove(cleanName);
            User user = userDAO.getUserByUsername(cleanName);
            if (user != null) {
                userDAO.updateOnlineStatus(user.getId(), false);
            }
            System.out.println("Ngắt kết nối: " + cleanName);
            broadcastOnlineStatus(cleanName, false);
        }
    }

    public static void sendFriendSignal(String username) {
        Session s = clients.get(username);
        if (s != null && s.isOpen()) {
            try {
                s.getBasicRemote().sendText("FRIEND_UPDATE");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @OnError
    public void onError(Throwable t) {
        t.printStackTrace();
    }

    private void broadcastOnlineStatus(String username, boolean isOnline) throws IOException {
        String msg = "STATUS_UPDATE:" + username + "|" + (isOnline ? "ONLINE" : "OFFLINE");
        broadcast(msg);
    }

    private void broadcast(String msg) throws IOException {
        for (Session s : clients.values()) {
            if (s.isOpen()) {
                s.getBasicRemote().sendText(msg);
            }
        }
    }
}