USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'web_chat_db')
BEGIN
    ALTER DATABASE web_chat_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE web_chat_db;
END
GO

-- Tạo Database
CREATE DATABASE web_chat_db;
GO

USE web_chat_db;
GO

-- Table: users
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100),
    role VARCHAR(20) DEFAULT 'USER',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    is_online BIT DEFAULT 0,
    last_seen DATETIME DEFAULT GETDATE(),
    created_at DATETIME DEFAULT GETDATE(),
    banned_until DATETIME DEFAULT NULL,
    login_count INT DEFAULT 0
);

-- Table: friends
CREATE TABLE friends (
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE NO ACTION
);

-- Table: chat_groups
CREATE TABLE chat_groups (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    created_by INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Table: group_members
CREATE TABLE group_members (
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(20) DEFAULT 'MEMBER',
    joined_at DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES chat_groups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE NO ACTION
);

-- Table: messages
CREATE TABLE messages (
    id INT IDENTITY(1,1) PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT DEFAULT NULL,
    group_id INT DEFAULT NULL,
    content NVARCHAR(MAX) NOT NULL,
    type VARCHAR(20) DEFAULT 'TEXT',
    sent_at DATETIME DEFAULT GETDATE(),
    is_read BIT DEFAULT 0,
    is_deleted BIT DEFAULT 0,
    is_edited BIT DEFAULT 0,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE NO ACTION,
    FOREIGN KEY (group_id) REFERENCES chat_groups(id) ON DELETE NO ACTION
);

-- Table: reports
CREATE TABLE reports (
    id INT IDENTITY(1,1) PRIMARY KEY,
    reporter_id INT NOT NULL,
    reported_id INT NOT NULL,
    message_id INT DEFAULT NULL,
    reason NVARCHAR(MAX) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE NO ACTION,
    FOREIGN KEY (reported_id) REFERENCES users(id) ON DELETE NO ACTION,
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE
);

-- Initial Admin Account (password: admin123 hashed with SHA-256)
INSERT INTO users (username, password, full_name, role) 
VALUES ('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'System Administrator', 'ADMIN');
GO
