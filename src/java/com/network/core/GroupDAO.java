package com.network.core;

import com.network.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GroupDAO {
    
    public List<Object[]> getAllGroups() {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT g.*, u.username as creator_name, " +
                     "(SELECT COUNT(*) FROM group_members WHERE group_id = g.id) as member_count " +
                     "FROM [groups] g " +
                     "JOIN [users] u ON g.created_by = u.id " +
                     "ORDER BY g.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Object[] row = new Object[5];
                row[0] = rs.getInt("id");
                row[1] = rs.getString("name");
                row[2] = rs.getString("creator_name");
                row[3] = rs.getInt("member_count");
                row[4] = rs.getTimestamp("created_at");
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getGroupMembers(int groupId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.* FROM [group_members] gm JOIN [users] u ON gm.user_id = u.id WHERE gm.group_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addMember(int groupId, int userId) {
        String sql = "INSERT INTO group_members (group_id, user_id) VALUES (?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeMember(int groupId, int userId) {
        String sql = "DELETE FROM group_members WHERE group_id = ? AND user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteGroup(int groupId) {
        // Delete members first, then messages, then group
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Delete members
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM group_members WHERE group_id = ?")) {
                    ps.setInt(1, groupId);
                    ps.executeUpdate();
                }
                // 2. Delete messages
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM messages WHERE group_id = ?")) {
                    ps.setInt(1, groupId);
                    ps.executeUpdate();
                }
                // 3. Delete group
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM [groups] WHERE id = ?")) {
                    ps.setInt(1, groupId);
                    int res = ps.executeUpdate();
                    conn.commit();
                    return res > 0;
                }
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
