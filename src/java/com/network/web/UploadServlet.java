package com.network.web;

import com.network.core.UserDAO;
import com.network.model.User;
import java.io.File;
import java.io.IOException;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/upload")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class UploadServlet extends HttpServlet {
    
    private static final String UPLOAD_DIR = "uploads";
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.setStatus(401);
            return;
        }

        User dbUser = userDAO.getUserById(user.getId());
        if (dbUser != null && "BANNED".equals(dbUser.getStatus())) {
            response.setStatus(403);
            return;
        }

        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
        
        File fileSaveDir = new File(uploadFilePath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdirs();
        }

        String fileName = "";
        for (Part part : request.getParts()) {
            String originalFileName = part.getSubmittedFileName();
            if (originalFileName != null && !originalFileName.isEmpty()) {
                String extension = originalFileName.substring(originalFileName.lastIndexOf("."));
                fileName = UUID.randomUUID().toString() + extension;
                part.write(uploadFilePath + File.separator + fileName);
            }
        }

        response.setContentType("text/plain");
        response.getWriter().write(UPLOAD_DIR + "/" + fileName);
    }
}
