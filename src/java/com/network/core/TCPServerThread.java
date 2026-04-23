/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.network.core;

/**
 *
 * @author admin
 */
import java.io.*;
import java.net.*;

public class TCPServerThread extends Thread {
    private int port;
    public TCPServerThread(int port) { this.port = port; }

    @Override
    public void run() {
        try (ServerSocket serverSocket = new ServerSocket(port)) {
            System.out.println("TCP Server started on port " + port);
            while (true) {
                Socket clientSocket = serverSocket.accept();
                new Thread(new ClientHandler(clientSocket)).start();
            }
        } catch (IOException e) { e.printStackTrace(); }
    }
}

class ClientHandler implements Runnable {
    private Socket socket;
    public ClientHandler(Socket s) { this.socket = s; }

    @Override
    public void run() {
        try (BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
             PrintWriter out = new PrintWriter(socket.getOutputStream(), true)) {
            
            // Dòng đầu tiên client gửi lên là Username
            String username = in.readLine();
            ChatManager.onlineUsers.put(username, out);
            ChatManager.broadcast(username + " đã tham gia mạng nội bộ.");

            String input;
            while ((input = in.readLine()) != null) {
                // Giao thức: "receiver|message"
                if (input.contains("|")) {
                    String[] data = input.split("\\|");
                    ChatManager.sendPrivate(data[0], username + ": " + data[1]);
                }
            }
        } catch (IOException e) { e.printStackTrace(); }
    }
}