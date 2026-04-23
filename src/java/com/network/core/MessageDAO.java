package com.network.core;

import com.network.model.Message;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MessageDAO {

    public int saveMessage(Message msg) {
        String sql = "INSERT INTO [messages] ([sender_id], [receiver_id], [group_id], [content], [type]) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, msg.getSenderId());
            if (msg.getReceiverId() != null) ps.setInt(2, msg.getReceiverId()); else ps.setNull(2, Types.INTEGER);
            if (msg.getGroupId() != null) ps.setInt(3, msg.getGroupId()); else ps.setNull(3, Types.INTEGER);
            ps.setString(4, msg.getContent());
            ps.setString(5, msg.getType() == null ? "TEXT" : msg.getType());
            
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<Message> getPrivateMessages(int user1, int user2) {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.*, u.[username] as [sender_name] FROM [messages] m " +
                     "JOIN [users] u ON m.[sender_id] = u.[id] " +
                     "WHERE ([sender_id] = ? AND [receiver_id] = ?) OR ([sender_id] = ? AND [receiver_id] = ?) " +
                     "ORDER BY [sent_at] ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, user1);
            ps.setInt(2, user2);
            ps.setInt(3, user2);
            ps.setInt(4, user1);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapMessage(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Message> getGroupMessages(int groupId) {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.*, u.[username] as [sender_name] FROM [messages] m " +
                     "JOIN [users] u ON m.[sender_id] = u.[id] " +
                     "WHERE " + (groupId == 0 ? "[group_id] IS NULL " : "[group_id] = ? ") +
                     "ORDER BY [sent_at] ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (groupId != 0) ps.setInt(1, groupId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapMessage(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Message> getMediaMessages() {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.*, u.[username] as [sender_name] FROM [messages] m " +
                     "JOIN [users] u ON m.[sender_id] = u.[id] " +
                     "WHERE [type] != 'TEXT' " +
                     "ORDER BY [sent_at] DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapMessage(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean deleteMessage(int id) {
        String sql = "DELETE FROM [messages] WHERE [id] = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean recallMessage(int id, int senderId) {
        String sql = "UPDATE [messages] SET [is_deleted] = 1 WHERE [id] = ? AND [sender_id] = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, senderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean editMessage(int id, int senderId, String newContent) {
        String sql = "UPDATE [messages] SET [content] = ?, [is_edited] = 1 WHERE [id] = ? AND [sender_id] = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newContent);
            ps.setInt(2, id);
            ps.setInt(3, senderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) FROM [messages] WHERE [receiver_id] = ? AND [is_read] = 0 AND [is_deleted] = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Map<Integer, Integer> getUnreadCountsPerSender(int userId) {
        Map<Integer, Integer> counts = new HashMap<>();
        String sql = "SELECT [sender_id], COUNT(*) as [count] FROM [messages] " +
                     "WHERE [receiver_id] = ? AND [is_read] = 0 AND [is_deleted] = 0 " +
                     "GROUP BY [sender_id]";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                counts.put(rs.getInt("sender_id"), rs.getInt("count"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    private Message mapMessage(ResultSet rs) throws SQLException {
        Message m = new Message();
        m.setId(rs.getInt("id"));
        m.setSenderId(rs.getInt("sender_id"));
        m.setReceiverId(rs.getObject("receiver_id", Integer.class));
        m.setGroupId(rs.getObject("group_id", Integer.class));
        m.setContent(rs.getString("content"));
        m.setType(rs.getString("type"));
        m.setSentAt(rs.getTimestamp("sent_at"));
        m.setSenderName(rs.getString("sender_name"));
        try {
            m.setRead(rs.getBoolean("is_read"));
            m.setEdited(rs.getBoolean("is_edited"));
            m.setDeleted(rs.getBoolean("is_deleted"));
        } catch (Exception e) {
            m.setRead(false);
            m.setEdited(false);
            m.setDeleted(false);
        }
        return m;
    }
}
