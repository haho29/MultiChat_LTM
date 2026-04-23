package com.network.model;

import java.sql.Timestamp;

public class Message {
    private int id;
    private int senderId;
    private Integer receiverId;
    private Integer groupId;
    private String content;
    private String type;
    private Timestamp sentAt;
    
    // UI help fields
    private String senderName;
    private boolean isRead;
    private boolean isEdited;
    private boolean isDeleted;

    public Message() {}

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }
    public Integer getReceiverId() { return receiverId; }
    public void setReceiverId(Integer receiverId) { this.receiverId = receiverId; }
    public Integer getGroupId() { return groupId; }
    public void setGroupId(Integer groupId) { this.groupId = groupId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Timestamp getSentAt() { return sentAt; }
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }
    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }
    public boolean isEdited() { return isEdited; }
    public void setEdited(boolean edited) { this.isEdited = edited; }
    public boolean isDeleted() { return isDeleted; }
    public void setDeleted(boolean deleted) { this.isDeleted = deleted; }
}
