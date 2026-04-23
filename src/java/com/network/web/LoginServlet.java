/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.network.web;

import com.network.core.UserDAO;
import com.network.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String user = request.getParameter("username");
        String pass = request.getParameter("password");

        User validatedUser = userDAO.login(user, pass);
        
        if (validatedUser != null) {
            if ("BANNED".equalsIgnoreCase(validatedUser.getStatus()) || "LOCKED".equalsIgnoreCase(validatedUser.getStatus())) {
                request.setAttribute("error", "Your account is " + validatedUser.getStatus().toLowerCase() + ".");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("user", validatedUser);
            
            if ("ADMIN".equals(validatedUser.getRole())) {
                response.sendRedirect("admin.jsp");
            } else {
                response.sendRedirect("chat.jsp");
            }
        } else {
            request.setAttribute("error", "Invalid username or password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}