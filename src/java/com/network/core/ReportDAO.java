package com.network.core;

import com.network.model.Report;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {
    
    public boolean saveReport(int reporterId, int reportedId, String reason, String content, Integer messageId) {
        String sql = "INSERT INTO [reports] ([reporter_id], [reported_id], [reason], [message_id], [status]) VALUES (?, ?, ?, ?, 'PENDING')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reporterId);
            ps.setInt(2, reportedId);
            ps.setString(3, "Lý do: " + reason + " | Nội dung: " + content);
            if (messageId != null) ps.setInt(4, messageId); else ps.setNull(4, Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Report> getAllReports() {
        List<Report> list = new ArrayList<>();
        String sql = "SELECT r.*, u1.username as reporter_name, u2.username as reported_name, m.content as msg_content " +
                     "FROM [reports] r " +
                     "JOIN [users] u1 ON r.reporter_id = u1.id " +
                     "JOIN [users] u2 ON r.reported_id = u2.id " +
                     "LEFT JOIN [messages] m ON r.message_id = m.id " +
                     "ORDER BY r.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Report r = new Report();
                r.setId(rs.getInt("id"));
                r.setReporterId(rs.getInt("reporter_id"));
                r.setReportedId(rs.getInt("reported_id"));
                r.setMessageId(rs.getObject("message_id", Integer.class));
                r.setReason(rs.getString("reason"));
                r.setStatus(rs.getString("status"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                r.setReporterName(rs.getString("reporter_name"));
                r.setReportedName(rs.getString("reported_name"));
                r.setMessageContent(rs.getString("msg_content"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateReportStatus(int id, String status) {
        String sql = "UPDATE [reports] SET [status] = ? WHERE [id] = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
