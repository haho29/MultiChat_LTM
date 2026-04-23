/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.network.core;

/**
 *
 * @author admin
 */
import java.io.PrintWriter;
import java.util.concurrent.ConcurrentHashMap;

public class ChatManager {
    // Lưu trữ Username và luồng gửi dữ liệu tương ứng (TCP)
    public static ConcurrentHashMap<String, PrintWriter> onlineUsers = new ConcurrentHashMap<>();
    
    public static void broadcast(String msg) {
        onlineUsers.values().forEach(out -> out.println("ALL: " + msg));
    }

    public static void sendPrivate(String toUser, String msg) {
        PrintWriter out = onlineUsers.get(toUser);
        if (out != null) out.println("PRIVATE: " + msg);
    }
}