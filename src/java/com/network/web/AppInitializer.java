/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.network.web;

/**
 *
 * @author admin
 */

import com.network.core.*;
// Thay javax bằng jakarta
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener; 

@WebListener // Thêm dòng này để Tomcat tự nhận diện Listener
public class AppInitializer implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        new TCPServerThread(9000).start();
        new UDPDiscovery().start();
        System.out.println("Hệ thống Mạng TCP/UDP đã sẵn sàng!");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {}
}