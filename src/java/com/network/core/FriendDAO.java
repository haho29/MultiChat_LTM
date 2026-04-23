package com.network.core;

import com.network.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FriendDAO {

    public boolean sendFriendRequest(int userId, int friendId) {
        // Kiểm tra xem đã tồn tại bản ghi nào giữa 2 người chưa
        String checkSql = "SELECT 1 FROM [friends] WHERE ([user_id] = ? AND [friend_id] = ?) OR ([user_id] = ? AND [friend_id] = ?)";
        String insertSql = "INSERT INTO [friends] ([user_id], [friend_id], [status]) VALUES (?, ?, 'PENDING')";
        String updateSql = "UPDATE [friends] SET [status] = 'PENDING', [user_id] = ?, [friend_id] = ? WHERE ([user_id] = ? AND [friend_id] = ?) OR ([user_id] = ? AND [friend_id] = ?)";
        
        try (Connection conn = DBContext.getConnection()) {
            // Kiểm tra tồn tại
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, userId);
                psCheck.setInt(2, friendId);
                psCheck.setInt(3, friendId);
                psCheck.setInt(4, userId);
                ResultSet rs = psCheck.executeQuery();
                
                if (rs.next()) {
                    // Nếu đã tồn tại, cập nhật lại trạng thái thành PENDING
                    try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                        psUpdate.setInt(1, userId);
                        psUpdate.setInt(2, friendId);
                        psUpdate.setInt(3, userId);
                        psUpdate.setInt(4, friendId);
                        psUpdate.setInt(5, friendId);
                        psUpdate.setInt(6, userId);
                        return psUpdate.executeUpdate() > 0;
                    }
                } else {
                    // Nếu chưa tồn tại, chèn mới
                    try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                        psInsert.setInt(1, userId);
                        psInsert.setInt(2, friendId);
                        return psInsert.executeUpdate() > 0;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateFriendStatus(int userId, int friendId, String status) {
        String sql = "UPDATE [friends] SET [status] = ? WHERE ([user_id] = ? AND [friend_id] = ?) OR ([user_id] = ? AND [friend_id] = ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            ps.setInt(3, friendId);
            ps.setInt(4, friendId);
            ps.setInt(5, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User> getFriendsList(int userId) {
        List<User> list = new ArrayList<>();
        // Lấy những người là bạn (ACCEPTED) của người dùng hiện tại
        String sql = "SELECT u.* FROM [users] u WHERE u.id IN (" +
                     "  SELECT friend_id FROM [friends] WHERE user_id = ? AND status = 'ACCEPTED' " +
                     "  UNION " +
                     "  SELECT user_id FROM [friends] WHERE friend_id = ? AND status = 'ACCEPTED'" +
                     ") AND u.id != ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getPendingRequests(int userId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.* FROM [users] u JOIN [friends] f ON u.[id] = f.[user_id] " +
                     "WHERE f.[friend_id] = ? AND f.[status] = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean isFriend(int userId, int friendId) {
        String sql = "SELECT 1 FROM [friends] WHERE (([user_id] = ? AND [friend_id] = ?) OR ([user_id] = ? AND [friend_id] = ?)) AND [status] = 'ACCEPTED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, friendId);
            ps.setInt(3, friendId);
            ps.setInt(4, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User[]> getAllFriendships() {
        List<User[]> list = new ArrayList<>();
        String sql = "SELECT u1.id as id1, u1.username as user1, u2.id as id2, u2.username as user2, f.status, f.created_at " +
                     "FROM [friends] f " +
                     "JOIN [users] u1 ON f.user_id = u1.id " +
                     "JOIN [users] u2 ON f.friend_id = u2.id " +
                     "ORDER BY f.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u1 = new User();
                u1.setId(rs.getInt("id1"));
                u1.setUsername(rs.getString("user1"));
                u1.setStatus(rs.getString("status")); // Reuse status to store friendship status for simplicity in array
                u1.setCreatedAt(rs.getTimestamp("created_at"));

                User u2 = new User();
                u2.setId(rs.getInt("id2"));
                u2.setUsername(rs.getString("user2"));
                
                list.add(new User[]{u1, u2});
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean deleteFriendship(int u1, int u2) {
        String sql = "DELETE FROM [friends] WHERE ([user_id] = ? AND [friend_id] = ?) OR ([user_id] = ? AND [friend_id] = ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, u1);
            ps.setInt(2, u2);
            ps.setInt(3, u2);
            ps.setInt(4, u1);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User> getSentRequests(int userId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.* FROM [friends] f JOIN [users] u ON f.friend_id = u.id " +
                     "WHERE f.user_id = ? AND f.status = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapUser(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username") != null ? rs.getString("username").trim() : "");
        u.setFullName(rs.getString("full_name") != null ? rs.getString("full_name").trim() : "");
        u.setRole(rs.getString("role") != null ? rs.getString("role").trim() : "USER");
        u.setStatus(rs.getString("status") != null ? rs.getString("status").trim() : "ACTIVE");
        u.setOnline(rs.getBoolean("is_online"));
        // Assuming banned_until exists in User model but might not be in all queries
        try {
            u.setBannedUntil(rs.getTimestamp("banned_until"));
        } catch (Exception e) {}
        return u;
    }
}
