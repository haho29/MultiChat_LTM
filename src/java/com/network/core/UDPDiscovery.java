/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.network.core;

/**
 *
 * @author admin
 */
import java.net.*;

public class UDPDiscovery extends Thread {
    @Override
    public void run() {
        try (DatagramSocket socket = new DatagramSocket(9001)) {
            byte[] buffer = new byte[256];
            while (true) {
                DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
                socket.receive(packet); // Nhận yêu cầu tìm kiếm từ Client
                String response = "SERVER_IP_HERE"; 
                byte[] resData = response.getBytes();
                DatagramPacket resPacket = new DatagramPacket(resData, resData.length, 
                                           packet.getAddress(), packet.getPort());
                socket.send(resPacket);
            }
        } catch (Exception e) { e.printStackTrace(); }
    }
}
