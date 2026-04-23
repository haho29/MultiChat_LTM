package com.network.core;

import com.network.model.User;
import java.util.List;

public class TestSearch {
    public static void main(String[] args) {
        UserDAO dao = new UserDAO();
        List<User> users = dao.searchUsersWithFilter(null, "ALL");
        System.out.println("Total users found: " + users.size());
        for (User u : users) {
            System.out.println("- " + u.getUsername() + " (Status: " + u.getStatus() + ")");
        }
    }
}
