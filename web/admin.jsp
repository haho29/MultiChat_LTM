<%@page import="com.network.model.Report"%>
<%@page import="java.util.List"%>
<%@page import="com.network.model.User"%>
<%@page import="com.network.model.Message"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản trị hệ thống - SkyChat</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary: #c4b5fd;
            --primary-light: #f5f3ff;
            --bg: #fdf2f8;
            --text-dark: #475569;
            --text-muted: #94a3b8;
            --primary-gradient: linear-gradient(135deg, #fbcfe8 0%, #ddd6fe 50%, #bfdbfe 100%);
        }
        body {
            background-color: var(--bg);
            font-family: 'Outfit', 'Inter', system-ui, -apple-system, sans-serif;
            color: var(--text-dark);
        }
        .navbar {
            background: white;
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(0,0,0,0.05);
            padding: 1rem 0;
        }
        .card {
            border: none;
            border-radius: 20px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
            transition: transform 0.2s;
            overflow: hidden;
        }
        .card-header {
            background: white !important;
            border-bottom: 1px solid #f1f5f9;
            padding: 1.5rem;
        }
        .table thead th {
            background: #f8fafc;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.05em;
            color: var(--text-muted);
            border: none;
            padding: 1rem;
        }
        .table tbody td {
            padding: 1rem;
            border-bottom: 1px solid #f1f5f9;
        }
        .status-badge {
            padding: 0.4rem 1rem;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .status-active { background: #dcfce7; color: #166534; }
        .status-banned { background: #fee2e2; color: #991b1b; }
        .status-pending { background: #fff7ed; color: #9a3412; }
        .btn-action {
            width: 32px;
            height: 32px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            transition: all 0.2s;
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>

<nav class="navbar navbar-expand-lg mb-4">
    <div class="container">
        <a class="navbar-brand fw-bold" style="background: var(--primary-gradient); -webkit-background-clip: text; -webkit-text-fill-color: transparent;" href="#"><i class="bi bi-shield-check me-2" style="color: var(--primary)"></i>SkyChat Admin</a>
                <div class="d-flex gap-2">
                    <a href="logout" class="btn btn-danger rounded-pill px-4">Đăng xuất</a>
                </div>
    </div>
</nav>

<div class="container py-4">
    <!-- Statistics Overview -->
    <% 
        java.util.Map<String, Object> stats = (java.util.Map<String, Object>) request.getAttribute("stats");
    %>
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card p-3 text-center bg-white border-0 shadow-sm rounded-4">
                <div class="display-6 fw-bold text-primary"><%= stats.get("totalUsers") %></div>
                <div class="small text-muted text-uppercase">Người dùng</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3 text-center bg-white border-0 shadow-sm rounded-4">
                <div class="display-6 fw-bold text-success"><%= stats.get("onlineUsers") %></div>
                <div class="small text-muted text-uppercase">Đang Online</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3 text-center bg-white border-0 shadow-sm rounded-4">
                <div class="display-6 fw-bold text-info"><%= stats.get("messagesToday") %></div>
                <div class="small text-muted text-uppercase">Tin nhắn hôm nay</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3 text-center bg-white border-0 shadow-sm rounded-4">
                <div class="display-6 fw-bold text-danger"><%= stats.get("pendingReports") %></div>
                <div class="small text-muted text-uppercase">Báo cáo chờ</div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- System Actions & Broadcast -->
        <div class="col-lg-4">
            <div class="card h-100">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold">Thông báo hệ thống</h5>
                </div>
                <div class="card-body">
                    <form action="admin" method="GET" class="mb-4">
                        <input type="hidden" name="action" value="broadcast">
                        <textarea name="message" class="form-control mb-2 rounded-3" rows="3" placeholder="Gửi thông báo tới toàn bộ người dùng..."></textarea>
                        <button type="submit" class="btn btn-primary w-100 rounded-pill">Gửi Broadcast</button>
                    </form>
                    <hr>
                    <h6 class="fw-bold small text-muted text-uppercase mb-3">Cấu hình nhanh</h6>
                    <div class="d-grid gap-2">
                        <button class="btn btn-outline-secondary btn-sm rounded-pill" onclick="showConfig()">Cấu hình hệ thống</button>
                        <button class="btn btn-outline-info btn-sm rounded-pill">Sao lưu dữ liệu</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- User Management -->
        <div class="col-lg-8">
            <div class="card">
                <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">Quản lý người dùng</h5>
                    <form class="d-flex gap-2" action="admin" method="GET">
                        <select name="status" class="form-select form-select-sm" style="width: 150px;">
                            <option value="ALL" <%= "ALL".equals(request.getAttribute("statusFilter")) || request.getAttribute("statusFilter") == null ? "selected" : "" %>>Tất cả trạng thái</option>
                            <option value="ACTIVE" <%= "ACTIVE".equals(request.getAttribute("statusFilter")) ? "selected" : "" %>>Đang hoạt động</option>
                            <option value="BANNED" <%= "BANNED".equals(request.getAttribute("statusFilter")) ? "selected" : "" %>>Bị khóa</option>
                        </select>
                        <input type="text" name="search" class="form-control form-control-sm" placeholder="Tìm tên/username..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" style="width: 200px;">
                        <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search"></i></button>
                    </form>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Người dùng</th>
                                    <th>Hoạt động</th>
                                    <th>Trạng thái</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    List<User> users = (List<User>) request.getAttribute("users");
                                    if (users != null) {
                                        for (User u : users) {
                                            if ("ADMIN".equals(u.getRole())) continue;
                                %>
                                <tr>
                                    <td><%= u.getId() %></td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="avatar bg-light text-primary" style="width: 32px; height: 32px; font-size: 0.8rem; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                                                <%= (u.getUsername() != null && !u.getUsername().isEmpty()) ? u.getUsername().substring(0, 1).toUpperCase() : "?" %>
                                            </div>
                                            <div>
                                                <div class="fw-bold">@<%= u.getUsername() %></div>
                                                <div class="small text-muted"><%= u.getFullName() %></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="small">
                                            <div><i class="bi bi-box-arrow-in-right me-1"></i><%= u.getLoginCount() %> lần đăng nhập</div>
                                            <div class="text-muted"><i class="bi bi-clock-history me-1"></i><%= u.getLastSeen() != null ? u.getLastSeen().toString().substring(0, 16) : "Chưa có" %></div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= "ACTIVE".equals(u.getStatus()) ? (u.isBanned() ? "status-pending" : "status-active") : "status-banned" %>">
                                            <%= u.isBanned() ? "CẤM CHAT" : u.getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <button class="btn btn-outline-primary btn-sm rounded-pill px-3" 
                                                onclick="showUserDetail('<%= u.getId() %>', '<%= u.getUsername() %>', '<%= u.getFullName() %>', '<%= u.getRole() %>', '<%= u.getStatus() %>', '<%= u.isBanned() ? u.getBannedUntil().toString().substring(0, 16) : "Không" %>', '<%= u.getLoginCount() %>', '<%= u.getLastSeen() %>')">
                                            Chi tiết
                                        </button>
                                    </td>
                                </tr>
                                <% 
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">
                                        <i class="bi bi-people me-2"></i>Không tìm thấy người dùng nào
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Reports Management -->
        <div class="col-12">
            <div class="card">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold">Báo cáo vi phạm</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Ngày gửi</th>
                                    <th>Người báo cáo</th>
                                    <th>Người bị báo cáo</th>
                                    <th>Nội dung</th>
                                    <th>Trạng thái</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    List<Report> reports = (List<Report>) request.getAttribute("reports");
                                    if (reports != null) {
                                        for (Report r : reports) {
                                %>
                                <tr>
                                    <td class="small text-muted"><%= r.getCreatedAt().toString().substring(0, 16) %></td>
                                    <td>@<%= r.getReporterName() %></td>
                                    <td class="fw-bold text-danger">@<%= r.getReportedName() %></td>
                                    <td>
                                        <div class="text-truncate" style="max-width: 150px;"><small><%= r.getReason() %></small></div>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= "PENDING".equals(r.getStatus()) ? "status-pending" : "status-active" %>">
                                            <%= r.getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="d-flex gap-1">
                                            <button class="btn btn-info btn-sm rounded-pill text-white" 
                                                    onclick="showReportDetail('<%= r.getId() %>', '<%= r.getReporterName() %>', '<%= r.getReportedName() %>', '<%= r.getReportedId() %>', '<%= r.getReason().replace("'", "\\'") %>', '<%= r.getMessageContent() != null ? r.getMessageContent().replace("'", "\\'") : "" %>', '<%= r.getMessageId() %>')">
                                                Xem
                                            </button>
                                            <% if ("PENDING".equals(r.getStatus())) { %>
                                                <a href="admin?action=resolve_report&id=<%= r.getId() %>" class="btn btn-outline-success btn-sm rounded-pill">
                                                    Xử lý
                                                </a>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% 
                                        }
                                    } 
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Friendship Management -->
        <div class="col-12">
            <div class="card">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold">Quản lý kết bạn & Mối quan hệ</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Người gửi</th>
                                    <th>Người nhận</th>
                                    <th>Ngày tạo</th>
                                    <th>Trạng thái</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    List<User[]> friendships = (List<User[]>) request.getAttribute("friendships");
                                    if (friendships != null) {
                                        for (User[] pair : friendships) {
                                %>
                                <tr>
                                    <td><span class="fw-bold text-primary">@<%= pair[0].getUsername() %></span></td>
                                    <td><span class="fw-bold text-info">@<%= pair[1].getUsername() %></span></td>
                                    <td class="small text-muted"><%= pair[0].getCreatedAt().toString().substring(0, 16) %></td>
                                    <td>
                                        <span class="badge <%= "ACCEPTED".equals(pair[0].getStatus()) ? "bg-success" : "bg-warning" %>">
                                            <%= pair[0].getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="admin?action=delete_friendship&u1=<%= pair[0].getId() %>&u2=<%= pair[1].getId() %>" 
                                           class="btn btn-outline-danger btn-sm rounded-pill"
                                           onclick="return confirm('Bạn có chắc muốn xóa mối quan hệ này?')">
                                            Hủy kết bạn
                                        </a>
                                    </td>
                                </tr>
                                <% 
                                        }
                                    } 
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        </div>
    </div>

    <!-- Group Management -->
    <div class="row g-4 mt-2">
        <div class="col-12">
            <div class="card">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold">Quản lý Nhóm chat</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Tên nhóm</th>
                                    <th>Người tạo</th>
                                    <th>Thành viên</th>
                                    <th>Ngày tạo</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    List<Object[]> groups = (List<Object[]>) request.getAttribute("groups");
                                    if (groups != null && !groups.isEmpty()) {
                                        for (Object[] g : groups) {
                                %>
                                <tr>
                                    <td><span class="fw-bold text-primary"><%= g[1] %></span></td>
                                    <td>@<%= g[2] %></td>
                                    <td><span class="badge bg-light text-dark"><%= g[3] %> tv</span></td>
                                    <td class="small text-muted"><%= g[4].toString().substring(0, 16) %></td>
                                    <td>
                                        <div class="d-flex gap-1">
                                            <button class="btn btn-outline-primary btn-sm rounded-pill" onclick="manageGroupMembers('<%= g[0] %>', '<%= g[1] %>')">Thành viên</button>
                                            <a href="admin?action=delete_group&groupId=<%= g[0] %>" 
                                               class="btn btn-outline-danger btn-sm rounded-pill"
                                               onclick="return confirm('Bạn có chắc muốn giải tán nhóm này và xóa toàn bộ tin nhắn?')">
                                                Giải tán
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                                <% 
                                        }
                                    } else {
                                %>
                                <tr><td colspan="5" class="text-center py-3 text-muted">Chưa có nhóm nào</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- File & Media Management -->
    <div class="row g-4 mt-2">
        <div class="col-12">
            <div class="card">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold">Quản lý File & Hình ảnh</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Loại</th>
                                    <th>Người gửi</th>
                                    <th>Nội dung/Preview</th>
                                    <th>Ngày gửi</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    List<Message> media = (List<Message>) request.getAttribute("media");
                                    if (media != null && !media.isEmpty()) {
                                        for (Message m : media) {
                                %>
                                <tr>
                                    <td><span class="badge bg-secondary text-uppercase"><%= m.getType() %></span></td>
                                    <td>@<%= m.getSenderName() %></td>
                                    <td>
                                        <% if ("IMAGE".equals(m.getType())) { %>
                                            <img src="<%= m.getContent() %>" style="max-height: 40px; border-radius: 4px;" alt="preview">
                                        <% } else { %>
                                            <div class="text-truncate" style="max-width: 200px;"><%= m.getContent() %></div>
                                        <% } %>
                                    </td>
                                    <td class="small text-muted"><%= m.getSentAt().toString().substring(0, 16) %></td>
                                    <td>
                                        <a href="admin?action=delete_message&msgId=<%= m.getId() %>" 
                                           class="btn btn-outline-danger btn-sm rounded-pill"
                                           onclick="return confirm('Xóa file/hình ảnh này?')">
                                            Xóa
                                        </a>
                                    </td>
                                </tr>
                                <% 
                                        }
                                    } else {
                                %>
                                <tr><td colspan="5" class="text-center py-3 text-muted">Chưa có file nào được tải lên</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Report Detail Modal -->
<div class="modal fade" id="reportDetailModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 24px;">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Chi tiết báo cáo</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="mb-3">
                    <label class="small text-muted">Người báo cáo</label>
                    <div class="fw-bold text-primary" id="modalReporter">@user</div>
                </div>
                <div class="mb-3">
                    <label class="small text-muted">Người bị báo cáo</label>
                    <div class="fw-bold text-danger" id="modalReported">@user</div>
                </div>
                <div class="mb-3">
                    <label class="small text-muted">Lý do & Nội dung báo cáo</label>
                    <div class="p-3 bg-light rounded-3 small" id="modalReason">Lý do...</div>
                </div>
                <div id="modalMsgSection" class="mb-4">
                    <label class="small text-muted">Tin nhắn bị báo cáo</label>
                    <div class="p-3 bg-warning bg-opacity-10 border border-warning border-opacity-25 rounded-3 italic" id="modalMsgContent">Nội dung tin nhắn...</div>
                </div>
                
                <div class="d-grid gap-2">
                    <button class="btn btn-danger rounded-pill" id="btnBanUser">Khóa tài khoản người vi phạm</button>
                    <button class="btn btn-outline-danger rounded-pill" id="btnDeleteMsg">Xóa tin nhắn vi phạm</button>
                    <button class="btn btn-outline-secondary rounded-pill" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- User Detail Modal -->
<div class="modal fade" id="userModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-primary text-white border-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-person-badge me-2"></i>Chi tiết người dùng</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="text-center mb-4">
                    <div class="avatar bg-light text-primary mx-auto mb-2" id="modalAvatar" style="width: 64px; height: 64px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2rem; font-weight: bold;">K</div>
                    <h4 class="mb-0 fw-bold" id="modalFullName">Họ tên</h4>
                    <p class="text-muted" id="modalUsername">@username</p>
                </div>
                
                <ul class="list-group list-group-flush mb-4">
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        Số lần đăng nhập <span class="fw-bold" id="modalLoginCount">0</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        Hoạt động cuối <span class="text-muted small" id="modalLastSeen">Chưa có</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        Trạng thái <span class="status-badge" id="modalStatusBadge">ACTIVE</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        Cấm chat đến <span class="text-danger fw-bold" id="modalBannedUntil">Không</span>
                    </li>
                </ul>

                <div class="d-grid gap-2">
                    <div class="btn-group w-100">
                        <button class="btn btn-warning dropdown-toggle" data-bs-toggle="dropdown">
                            <i class="bi bi-clock me-1"></i> Cấm chat tạm thời
                        </button>
                        <ul class="dropdown-menu w-100 shadow border-0">
                            <li><a class="dropdown-item" id="ban1h" href="#"><i class="bi bi-hourglass-split me-2"></i>Cấm 1 giờ</a></li>
                            <li><a class="dropdown-item" id="ban1d" href="#"><i class="bi bi-calendar-event me-2"></i>Cấm 1 ngày</a></li>
                            <li><a class="dropdown-item" id="ban1w" href="#"><i class="bi bi-calendar-range me-2"></i>Cấm 1 tuần</a></li>
                        </ul>
                    </div>
                    <a href="#" id="lockBtn" class="btn btn-outline-danger">
                        <i class="bi bi-person-x me-1"></i> Khóa tài khoản vĩnh viễn
                    </a>
                    <a href="#" id="unlockBtn" class="btn btn-success d-none">
                        <i class="bi bi-person-check me-1"></i> Mở khóa tài khoản
                    </a>
                    <hr>
                    <button id="deleteBtn" class="btn btn-danger" onclick="confirmDelete()">
                        <i class="bi bi-trash3 me-1"></i> Xóa tài khoản vĩnh viễn
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Group Members Modal -->
<div class="modal fade" id="groupMembersModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 24px;">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Thành viên: <span id="modalGroupName">Nhóm</span></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <form action="admin" method="GET" class="mb-3">
                    <input type="hidden" name="action" value="add_member">
                    <input type="hidden" name="groupId" id="modalGroupIdAdd">
                    <div class="input-group">
                        <input type="text" name="username" class="form-control rounded-start-pill" placeholder="Thêm username vào nhóm...">
                        <button type="submit" class="btn btn-success rounded-end-pill">Thêm</button>
                    </div>
                </form>
                <div class="list-group list-group-flush" id="modalMemberList" style="max-height: 300px; overflow-y: auto;">
                    <!-- Members will be loaded here -->
                </div>
            </div>
        </div>
    </div>
</div>

<!-- System Config Modal -->
<div class="modal fade" id="configModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 24px;">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold">Cấu hình hệ thống</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="mb-3">
                    <label class="form-label small fw-bold">Session Timeout (phút)</label>
                    <input type="number" class="form-control rounded-pill" value="30">
                </div>
                <div class="mb-3">
                    <label class="form-label small fw-bold">Giới hạn Upload (MB)</label>
                    <input type="number" class="form-control rounded-pill" value="10">
                </div>
                <div class="mb-3">
                    <label class="form-label small fw-bold">Chế độ bảo trì</label>
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox">
                        <label class="form-check-label">Kích hoạt</label>
                    </div>
                </div>
                <button class="btn btn-primary w-100 rounded-pill mt-3">Lưu cấu hình</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showConfig() {
        new bootstrap.Modal(document.getElementById('configModal')).show();
    }

    async function manageGroupMembers(groupId, groupName) {
        document.getElementById('modalGroupName').innerText = groupName;
        document.getElementById('modalGroupIdAdd').value = groupId;
        const list = document.getElementById('modalMemberList');
        list.innerHTML = '<div class="text-center p-3"><div class="spinner-border spinner-border-sm text-primary"></div></div>';
        
        new bootstrap.Modal(document.getElementById('groupMembersModal')).show();
        
        try {
            const res = await fetch('admin?action=get_members&groupId=' + groupId);
            const members = await res.json();
            list.innerHTML = '';
            members.forEach(u => {
                list.innerHTML += `
                    <div class="list-group-item d-flex justify-content-between align-items-center border-0 px-0">
                        <div>
                            <div class="fw-bold">@${u.username}</div>
                            <div class="small text-muted">${u.fullName}</div>
                        </div>
                        <a href="admin?action=remove_member&groupId=${groupId}&userId=${u.id}" 
                           class="btn btn-link text-danger btn-sm p-0" 
                           onclick="return confirm('Xóa người này khỏi nhóm?')">Xóa</a>
                    </div>
                `;
            });
            if (members.length === 0) list.innerHTML = '<div class="text-center text-muted p-3">Không có thành viên</div>';
        } catch (e) {
            list.innerHTML = '<div class="text-center text-danger p-3">Lỗi tải dữ liệu</div>';
        }
    }

    function showUserDetail(id, username, fullName, role, status, bannedUntil, loginCount, lastSeen) {
        document.getElementById('modalId').innerText = id;
        document.getElementById('modalUsername').innerText = '@' + username;
        document.getElementById('modalFullName').innerText = fullName;
        document.getElementById('modalRole').innerText = role;
        document.getElementById('modalAvatar').innerText = username[0].toUpperCase();
        document.getElementById('modalBannedUntil').innerText = bannedUntil;
        document.getElementById('modalLoginCount').innerText = loginCount;
        document.getElementById('modalLastSeen').innerText = lastSeen && lastSeen !== 'null' ? lastSeen.substring(0, 16) : "Chưa có";
        
        const badge = document.getElementById('modalStatusBadge');
        badge.innerText = status;
        badge.className = 'status-badge ' + (status === 'ACTIVE' ? 'status-active' : 'status-banned');

        const lockBtn = document.getElementById('lockBtn');
        const unlockBtn = document.getElementById('unlockBtn');
        
        if (status === 'ACTIVE') {
            lockBtn.classList.remove('d-none');
            lockBtn.href = 'admin?action=lock&id=' + id;
            unlockBtn.classList.add('d-none');
        } else {
            lockBtn.classList.add('d-none');
            unlockBtn.classList.remove('d-none');
            unlockBtn.href = 'admin?action=unlock&id=' + id;
        }

        // Update ban links
        document.getElementById('ban1h').href = `admin?action=ban&id=\${id}&minutes=60`;
        document.getElementById('ban1d').href = `admin?action=ban&id=\${id}&minutes=1440`;
        document.getElementById('ban1w').href = `admin?action=ban&id=\${id}&minutes=10080`;

        new bootstrap.Modal(document.getElementById('userModal')).show();
    }

    function showReportDetail(id, reporter, reported, reportedId, reason, msgContent, msgId) {
        document.getElementById('modalReporter').innerText = '@' + reporter;
        document.getElementById('modalReported').innerText = '@' + reported;
        document.getElementById('modalReason').innerText = reason;
        
        if (msgContent && msgContent !== 'null' && msgContent !== '') {
            document.getElementById('modalMsgSection').style.display = 'block';
            document.getElementById('modalMsgContent').innerText = msgContent;
            document.getElementById('btnDeleteMsg').style.display = 'block';
            document.getElementById('btnDeleteMsg').onclick = function() {
                if (confirm('Xóa tin nhắn này?')) {
                    location.href = 'admin?action=delete_message&msgId=' + msgId + '&reportId=' + id;
                }
            };
        } else {
            document.getElementById('modalMsgSection').style.display = 'none';
            document.getElementById('btnDeleteMsg').style.display = 'none';
        }
        
        document.getElementById('btnBanUser').onclick = function() {
            if (confirm('Khóa tài khoản này?')) {
                location.href = 'admin?action=lock&id=' + reportedId;
            }
        };
        
        new bootstrap.Modal(document.getElementById('reportDetailModal')).show();
    }

    function confirmDelete() {
        const id = document.getElementById('modalId').innerText;
        const username = document.getElementById('modalUsername').innerText;
        if (confirm(`BẠN CÓ CHẮC CHẮN MUỐN XÓA TÀI KHOẢN ${username}?\nHành động này không thể hoàn tác và sẽ xóa toàn bộ dữ liệu liên quan!`)) {
            window.location.href = `admin?action=delete&id=${id}`;
        }
    }
</script>
</body>
</html>
