<%@page import="com.network.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SkyChat - <%= currentUser.getFullName() %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-pink: #f9a8d4;
            --primary-blue: #93c5fd;
            --primary-purple: #c4b5fd;
            --primary-gradient: linear-gradient(135deg, #fbcfe8 0%, #ddd6fe 50%, #bfdbfe 100%);
            --bg-gradient: linear-gradient(120deg, #fdf2f8 0%, #f5f3ff 50%, #eff6ff 100%);
            --glass-bg: rgba(255, 255, 255, 0.85);
            --text-main: #475569;
            --text-muted: #94a3b8;
            --primary: #c4b5fd;
        }
        body {
            background: var(--bg-gradient);
            font-family: 'Outfit', 'Inter', system-ui, -apple-system, sans-serif;
            height: 100vh;
            margin: 0;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .main-container {
            width: 95vw;
            height: 90vh;
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
            display: flex;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.4);
        }
        /* Sidebar */
        .sidebar {
            width: 320px;
            background: rgba(255, 255, 255, 0.5);
            border-right: 1px solid rgba(0,0,0,0.05);
            display: flex;
            flex-direction: column;
        }
        .sidebar-header {
            padding: 1.5rem;
            background: white;
            border-bottom: 1px solid rgba(0,0,0,0.05);
        }
        .profile-section {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 1rem;
        }
        .avatar {
            width: 44px; height: 44px;
            background: var(--primary-gradient);
            color: white;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
        }
        .search-box input {
            border-radius: 12px;
            background: #f1f5f9;
            border: 1px solid transparent;
            padding: 10px 15px;
            transition: all 0.3s;
        }
        .search-box input:focus {
            background: white;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
        }
        .list-section { flex: 1; overflow-y: auto; }
        .section-label {
            padding: 1rem 1.5rem 0.5rem;
            font-size: 0.75rem;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
        }
        .nav-item-chat {
            padding: 12px 24px;
            cursor: pointer;
            display: flex; align-items: center; gap: 12px;
            transition: all 0.2s;
            border-left: 4px solid transparent;
        }
        .nav-item-chat:hover { background: rgba(99, 102, 241, 0.05); }
        .nav-item-chat.active {
            background: rgba(99, 102, 241, 0.1);
            border-left-color: var(--primary);
        }
        .status-dot {
            width: 10px; height: 10px;
            border-radius: 50%;
            background: #cbd5e1;
            border: 2px solid white;
        }
        .status-dot.online { background: #22c55e; }
        
        /* Chat Main */
        .chat-main { flex: 1; display: flex; flex-direction: column; background: white; }
        .chat-header {
            padding: 16px 24px;
            border-bottom: 1px solid rgba(0,0,0,0.05);
            display: flex; align-items: center; justify-content: space-between;
        }
        .messages-container {
            flex: 1;
            padding: 24px;
            overflow-y: auto;
            background-color: #ffffff;
            background-image: radial-gradient(#fbcfe8 1px, transparent 1px);
            background-size: 24px 24px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .message {
            width: fit-content;
            max-width: 80%;
            margin-bottom: 8px;
            padding: 10px 16px;
            border-radius: 18px;
            position: relative;
            animation: fadeIn 0.3s ease;
            line-height: 1.5;
            font-size: 0.95rem;
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } }
        .message-me {
            background: var(--primary-gradient);
            color: #4b2c20;
            align-self: flex-end;
            border-bottom-right-radius: 4px;
            box-shadow: 0 4px 15px rgba(249, 168, 212, 0.2);
            font-weight: 500;
        }
        .message-others {
            background: white;
            border: 1px solid #f1f5f9;
            color: var(--text-main);
            align-self: flex-start;
            border-bottom-left-radius: 4px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.02);
        }
        .msg-time { font-size: 0.7rem; opacity: 0.7; margin-top: 4px; display: block; }
        
        .chat-input-area { padding: 20px 24px; border-top: 1px solid rgba(0,0,0,0.05); }
        .input-wrapper {
            background: #f1f5f9;
            border-radius: 16px;
            padding: 8px 16px;
            display: flex; align-items: center; gap: 12px;
        }
        .input-wrapper input { background: transparent; border: none; flex: 1; padding: 8px 0; }
        .input-wrapper input:focus { outline: none; }
        .btn-send {
            background: var(--primary-gradient);
            color: white; border: none;
            width: 40px; height: 40px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            transition: transform 0.2s;
        }
        .btn-send:hover { transform: scale(1.05); }
        
        .badge-pending {
            background: #ef4444; color: white;
            font-size: 0.7rem; padding: 2px 8px;
            border-radius: 10px; margin-left: auto; cursor: pointer;
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>

<div class="main-container">
<div class="sidebar">
    <div class="sidebar-header">
        <div class="profile-section">
            <div class="avatar"><%= currentUser.getUsername().substring(0, 1).toUpperCase() %></div>
            <div class="flex-grow-1">
                <div class="fw-bold text-dark"><%= currentUser.getFullName() %></div>
                <div class="text-muted small">@<%= currentUser.getUsername() %> • Online</div>
            </div>
            <a href="logout" class="text-muted"><i class="bi bi-box-arrow-right"></i></a>
        </div>
        <div class="search-box">
            <i class="bi bi-search"></i>
            <input type="text" id="userSearch" class="form-control form-control-sm" placeholder="Tìm bạn mới..." onkeypress="if(event.keyCode==13) searchFriend()">
        </div>
        <div id="searchResult" class="px-3"></div>
    </div>

    <div class="list-section">
        <div class="nav-item-chat active" onclick="switchChat('ALL', 0, 'Phòng Hội Nhóm')">
            <div class="avatar" style="background: #fbbf24;"><i class="bi bi-people-fill"></i></div>
            <div class="fw-bold">Phòng Hội Nhóm</div>
        </div>

        <div class="section-label">Bạn bè</div>
        <div id="friendsList"></div>

        <div class="section-label">Lời mời đã nhận</div>
        <div id="incomingList" class="px-2"></div>

        <div class="section-label">Lời mời đã gửi</div>
        <div id="outgoingList" class="px-2"></div>
    </div>
</div>

<div class="chat-main">
    <div class="chat-header">
        <div class="d-flex align-items-center gap-3">
            <div id="headerAvatar" class="avatar">S</div>
            <div>
                <h6 id="chatTitle" class="mb-0 fw-bold">Phòng Hội Nhóm</h6>
                <small id="chatStatus" class="text-muted">Public Group</small>
                <div id="typingIndicator" class="text-primary small fw-bold d-none" style="font-style: italic;">đang nhập...</div>
            </div>
        </div>
        <div class="d-flex gap-2">
            <% if ("ADMIN".equals(currentUser.getRole())) { %>
                <a href="admin" class="btn btn-warning btn-sm rounded-circle" title="Admin Dashboard"><i class="bi bi-shield-lock"></i></a>
            <% } %>
            <button class="btn btn-light btn-sm rounded-circle"><i class="bi bi-telephone"></i></button>
            <button class="btn btn-light btn-sm rounded-circle"><i class="bi bi-info-circle"></i></button>
        </div>
    </div>

    <div id="messagesBox" class="messages-container">
        <!-- Messages go here -->
    </div>

    <div class="chat-input-area">
        <div class="input-wrapper">
            <input type="file" id="imageInput" style="display: none;" accept="image/*" onchange="uploadImage()">
            <button class="btn btn-link text-muted p-0" onclick="document.getElementById('imageInput').click()"><i class="bi bi-image"></i></button>
            <button class="btn btn-link text-muted p-0" data-bs-toggle="dropdown"><i class="bi bi-emoji-smile"></i></button>
            <div class="dropdown-menu p-2" style="width: 250px;">
                <div class="d-flex flex-wrap gap-2">
                    <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f600/512.gif" width="40" class="cursor-pointer" onclick="sendSticker('1f600')">
                    <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f60d/512.gif" width="40" class="cursor-pointer" onclick="sendSticker('1f60d')">
                    <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f602/512.gif" width="40" class="cursor-pointer" onclick="sendSticker('1f602')">
                    <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f62d/512.gif" width="40" class="cursor-pointer" onclick="sendSticker('1f62d')">
                    <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f44d/512.gif" width="40" class="cursor-pointer" onclick="sendSticker('1f44d')">
                    <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f525/512.gif" width="40" class="cursor-pointer" onclick="sendSticker('1f525')">
                </div>
            </div>
            <input type="text" id="msgInput" placeholder="Nhập tin nhắn..." onkeypress="if(event.keyCode==13) sendMessage()" oninput="handleTyping()">
            <button class="btn-send" onclick="sendMessage()"><i class="bi bi-send-fill"></i></button>
        </div>
    </div>
</div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const currentUser = "<%= currentUser.getUsername() %>";
    let currentTarget = "ALL";
    let currentTargetId = 0;
    
    // WebSocket Setup
    const socket = new WebSocket(((window.location.protocol === 'https:') ? 'wss://' : 'ws://') + window.location.host + "/BaiKiemTraLan2/chatServer/" + currentUser);

    socket.onmessage = function(event) {
        const data = event.data;
        if (data.startsWith("STATUS_UPDATE:")) {
            loadFriends();
            return;
        } else if (data.startsWith("TYPING_UPDATE:")) {
            const parts = data.split(":")[1].split("|");
            if (parts[0] === currentTarget) {
                document.getElementById("typingIndicator").classList.toggle("d-none", parts[1] === "STOP");
            }
            return;
        } else if (data.startsWith("READ_UPDATE:")) {
            const reader = data.split(":")[1];
            if (reader === currentTarget) {
                document.querySelectorAll('.msg-seen').forEach(el => el.innerText = "Đã xem");
            }
            return;
        } else if (data === "FRIEND_UPDATE") {
            loadFriends();
            return;
        }
        handleMessage(data);
    };

    function handleMessage(data) {
        const parts = data.split(":");
        const prefix = parts[0];
        const msgContent = parts.slice(1).join(":"); 
        const msgParts = msgContent.split("|");
        
        // Revised parsing: sender is first, type is last, time is second last
        // The rest in the middle is content
        const sender = msgParts[0];
        const isMeMarker = (msgParts[msgParts.length - 1] === "IS_ME");
        const type = isMeMarker ? msgParts[msgParts.length - 2] : msgParts[msgParts.length - 1];
        const time = isMeMarker ? msgParts[msgParts.length - 3] : msgParts[msgParts.length - 2];
        
        // content is everything between sender and time
        const contentStartIndex = msgContent.indexOf("|") + 1;
        const contentEndIndex = msgContent.lastIndexOf("|" + time);
        const content = msgContent.substring(contentStartIndex, contentEndIndex);

        const storageKey = (prefix === "FROM_ALL") ? "ALL" : sender;
        
        if (currentTarget === storageKey) {
            appendMessage(sender, content, time, isMeMarker || sender === currentUser, type, false);
            if (!isMeMarker && currentTarget !== 'ALL') {
                socket.send(`MARK_READ|${currentTarget}`);
            }
        }
    }

    function appendMessage(sender, content, time, isMe, type = "TEXT", isRead = false) {
        const box = document.getElementById("messagesBox");
        
        // Remove old 'Seen' labels from my previous messages
        if (isMe) {
            document.querySelectorAll('.msg-seen').forEach(el => el.innerText = "");
        }

        const div = document.createElement("div");
        div.className = `message \${isMe ? 'message-me' : 'message-others'}`;
        
        let htmlContent = content;
        if (type === "IMAGE") {
            htmlContent = `<img src="\${content}" class="img-fluid rounded-3 mt-1" style="max-width: 250px; cursor: pointer;" onclick="window.open('\${content}')">`;
        } else if (type === "STICKER") {
            htmlContent = `<img src="https://fonts.gstatic.com/s/e/notoemoji/latest/\${content}/512.gif" width="80" class="d-block">`;
            div.style.background = "none";
            div.style.padding = "0";
        }

        div.innerHTML = `
            \${!isMe && currentTarget === 'ALL' ? `<small class="fw-bold d-block mb-1 text-primary">\${sender}</small>` : ''}
            <div class="d-flex justify-content-between align-items-start gap-2">
                <div>\${htmlContent}</div>
                \${!isMe ? `<i class="bi bi-flag text-muted small cursor-pointer" onclick="reportUser('\${sender}', '\${content}')"></i>` : ''}
            </div>
            <span class="msg-time">\${time}</span>
            \${isMe && currentTarget !== 'ALL' ? `<span class="msg-seen small" style="font-size: 0.6rem; float: right; margin-top: -15px; margin-right: -40px; color: var(--primary);">\${isRead ? 'Đã xem' : ''}</span>` : ''}
        `;
        box.appendChild(div);
        box.scrollTop = box.scrollHeight;
    }

    async function reportUser(username, content) {
        const reason = prompt(`Báo cáo nội dung của \${username}:\n"\${content}"\n\nLý do:`);
        if (reason) {
            const formData = new URLSearchParams();
            formData.append('reportedId', currentTargetId);
            formData.append('reason', reason);
            formData.append('messageContent', content);
            
            await fetch('report', { method: 'POST', body: formData });
            alert("Đã gửi báo cáo cho Admin.");
        }
    }

    function sendMessage() {
        const input = document.getElementById("msgInput");
        const content = input.value.trim();
        if (content) {
            socket.send(`\${currentTarget}|\${content}|TEXT`);
            input.value = "";
            handleTyping(true); // Stop typing
        }
    }

    let typingTimer;
    let isTyping = false;
    function handleTyping(forceStop = false) {
        if (currentTarget === 'ALL') return;
        
        if (forceStop) {
            clearTimeout(typingTimer);
            if (isTyping) {
                socket.send(`TYPING_STOP|\${currentTarget}`);
                isTyping = false;
            }
            return;
        }

        if (!isTyping) {
            socket.send(`TYPING_START|\${currentTarget}`);
            isTyping = true;
        }
        
        clearTimeout(typingTimer);
        typingTimer = setTimeout(() => {
            socket.send(`TYPING_STOP|\${currentTarget}`);
            isTyping = false;
        }, 2000);
    }

    async function uploadImage() {
        const fileInput = document.getElementById("imageInput");
        const file = fileInput.files[0];
        if (!file) return;

        const formData = new FormData();
        formData.append("file", file);

        const res = await fetch("upload", { method: "POST", body: formData });
        if (res.ok) {
            const filePath = await res.text();
            socket.send(`\${currentTarget}|\${filePath}|IMAGE`);
        }
        fileInput.value = "";
    }

    function sendSticker(code) {
        socket.send(`\${currentTarget}|\${code}|STICKER`);
    }

    // AJAX Functions
    async function loadFriends() {
        // Load Accepted Friends
        const resFriends = await fetch("friend?type=list");
        const friends = await resFriends.json();
        const friendsList = document.getElementById("friendsList");
        friendsList.innerHTML = ""; // Clear old
        if (friends.length === 0) {
            friendsList.innerHTML = '<div class="small text-muted px-4 py-2">Chưa có bạn bè</div>';
        }
        friends.forEach(f => {
            const item = document.createElement("div");
            item.className = `nav-item-chat \${currentTarget === f.username ? 'active' : ''}`;
            item.onclick = () => switchChat(f.username, f.id, f.fullName);
            item.innerHTML = `
                <div class="avatar">\${f.username[0].toUpperCase()}</div>
                <div class="flex-grow-1">
                    <div class="fw-bold text-truncate" style="max-width: 150px;">\${f.fullName}</div>
                    <div class="small text-muted">@\${f.username}</div>
                </div>
                <div class="status-dot \${f.isOnline ? 'online' : ''}"></div>
            `;
            friendsList.appendChild(item);
        });

        // Load Incoming Requests
        const resIncoming = await fetch("friend?type=pending");
        const incoming = await resIncoming.json();
        const incomingList = document.getElementById("incomingList");
        incomingList.innerHTML = ""; // Clear old
        if (incoming.length === 0) {
            incomingList.innerHTML = '<div class="small text-muted px-3 py-1">Không có lời mời</div>';
        }
        incoming.forEach(p => {
            const div = document.createElement("div");
            div.className = "d-flex align-items-center justify-content-between p-2 mb-1 rounded bg-white shadow-sm border mx-2";
            div.innerHTML = `
                <div class="small fw-bold text-truncate me-1" title="\${p.fullName}">@\${p.username}</div>
                <div class="d-flex gap-1">
                    <button class="btn btn-primary btn-sm p-1 px-2" style="font-size: 0.7rem;" onclick="friendAction('accept', '\${p.username}')"><i class="bi bi-check"></i></button>
                    <button class="btn btn-light btn-sm p-1 px-2" style="font-size: 0.7rem;" onclick="friendAction('reject', '\${p.username}')"><i class="bi bi-x"></i></button>
                </div>
            `;
            incomingList.appendChild(div);
        });

        // Load Outgoing Requests
        const resOutgoing = await fetch("friend?type=sent");
        const outgoing = await resOutgoing.json();
        const outgoingList = document.getElementById("outgoingList");
        outgoingList.innerHTML = ""; // Clear old
        if (outgoing.length === 0) {
            outgoingList.innerHTML = '<div class="small text-muted px-3 py-1">Không có lời mời</div>';
        }
        outgoing.forEach(p => {
            const div = document.createElement("div");
            div.className = "d-flex align-items-center justify-content-between p-2 mb-1 rounded bg-white shadow-sm border mx-2";
            div.style.opacity = "0.8";
            div.innerHTML = `
                <div class="small text-muted text-truncate me-1">@\${p.username}</div>
                <button class="btn btn-outline-danger btn-sm p-0 px-2" style="font-size: 0.7rem;" onclick="friendAction('cancel', '\${p.username}')">Hủy</button>
            `;
            outgoingList.appendChild(div);
        });
        console.log("Debug: Loaded friends for", currentUser);
    }

    async function friendAction(action, username) {
        await fetch(`friend?action=\${action}&username=\${username}`, {method: 'POST'});
        loadFriends();
        if (action === 'accept') bootstrap.Modal.getInstance(document.getElementById('pendingModal')).hide();
    }

    async function searchFriend() {
        const input = document.getElementById("userSearch");
        const query = input.value.trim();
        const resultDiv = document.getElementById("searchResult");
        
        if (!query) {
            resultDiv.innerHTML = "";
            return;
        }

        const res = await fetch(`friend?type=search&query=\${query}`);
        const user = await res.json();
        
        if (user) {
            resultDiv.innerHTML = `
                <div class="d-flex align-items-center justify-content-between p-2 mt-2 rounded bg-primary text-white shadow-sm">
                    <div class="small">
                        <div class="fw-bold text-truncate" style="max-width: 120px;">\${user.fullName}</div>
                        <div style="font-size: 0.7rem; opacity: 0.8;">@\${user.username}</div>
                    </div>
                    <button class="btn btn-light btn-sm p-1 px-2" style="font-size: 0.7rem;" onclick="sendRequest('\${user.username}')">Kết bạn</button>
                </div>
            `;
        } else {
            resultDiv.innerHTML = `<div class="small text-danger mt-2 px-2">Không tìm thấy người này</div>`;
        }
    }

    async function sendRequest(username) {
        const res = await fetch(`friend?action=add&username=\${username}`, {method: 'POST'});
        const msg = await res.text();
        alert(msg);
        document.getElementById("searchResult").innerHTML = "";
        document.getElementById("userSearch").value = "";
        loadFriends();
    }

    async function switchChat(username, id, fullName) {
        currentTarget = username;
        currentTargetId = id;
        
        document.getElementById("chatTitle").innerText = fullName;
        document.getElementById("chatStatus").innerText = (username === 'ALL') ? "Public Group" : "Trò chuyện riêng";
        document.getElementById("headerAvatar").innerText = fullName[0].toUpperCase();
        document.getElementById("messagesBox").innerHTML = "";
        document.getElementById("typingIndicator").classList.add("d-none");
        
        if (username !== 'ALL') {
            socket.send(`MARK_READ|\${username}`);
        }
        
        // Highlight active
        document.querySelectorAll('.nav-item-chat').forEach(i => i.classList.remove('active'));
        // Load history
        const res = await fetch(`messages?target=\${username}&targetId=\${id}`);
        const history = await res.json();
        history.forEach(m => appendMessage(m.senderName, m.content, m.time, m.isMe, m.type));
    }

    // Initial Load
    loadFriends();
</script>

</div>

</body>
</html>