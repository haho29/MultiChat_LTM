package com.network.core;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestConnection {
    public static void main(String[] args) {
        System.out.println("--- Đang kiểm tra kết nối SQL Server ---");
        try {
            Connection conn = DBContext.getConnection();
            if (conn != null) {
                System.out.println("✅ KET NOI THANH CONG!");
                
                // Liệt kê danh sách username
                Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery("SELECT username, full_name FROM [users]");
                System.out.println("--- DANH SÁCH USERNAME TRONG DATABASE ---");
                while (rs.next()) {
                    System.out.println("Username: [" + rs.getString(1) + "] | Họ tên: " + rs.getString(2));
                }
                System.out.println("----------------------------------------");
                
                conn.close();
            } else {
                System.out.println("❌ KET NOI THAT BAI (Connection is null)");
            }
        } catch (Exception e) {
            System.out.println("❌ LOI KET NOI:");
            e.printStackTrace();
            
            System.out.println("\n--- Gợi ý xử lý lỗi ---");
            if (e.getMessage().contains("TCP/IP")) {
                System.out.println("-> Hãy kiểm tra xem TCP/IP trong SQL Server Configuration Manager đã được BẬT (Enabled) chưa.");
            } else if (e.getMessage().contains("login failed")) {
                System.out.println("-> Hãy kiểm tra lại USER và PASS trong file DBContext.java.");
            } else if (e.getMessage().contains("ClassNotfound")) {
                System.out.println("-> Thiếu thư viện mssql-jdbc. Hãy kiểm tra lại Libraries trong NetBeans.");
            }
        }
    }
}
