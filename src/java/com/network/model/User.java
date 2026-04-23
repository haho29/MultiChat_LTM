package com.network.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String username;
    private String password;
    private String fullName;
    private String role;
    private String status;
    private boolean isOnline;
    private Timestamp lastSeen;
    private Timestamp createdAt;
    private Timestamp bannedUntil;

    public User() {}

    public Timestamp getBannedUntil() { return bannedUntil; }
    public void setBannedUntil(Timestamp bannedUntil) { this.bannedUntil = bannedUntil; }

    public boolean isBanned() {
        if (bannedUntil == null) return false;
        return bannedUntil.after(new Timestamp(System.currentTimeMillis()));
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public boolean isOnline() { return isOnline; }
    public void setOnline(boolean online) { isOnline = online; }
    public Timestamp getLastSeen() { return lastSeen; }
    public void setLastSeen(Timestamp lastSeen) { this.lastSeen = lastSeen; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
