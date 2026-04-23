<%@page import="com.network.model.Report"%>
<%@page import="java.util.List"%>
<%@page import="com.network.model.User"%>
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
        <div class="ms-auto">
            <a href="chat.jsp" class="btn btn-outline-primary btn-sm me-2">Về trang Chat</a>
            <a href="logout" class="btn btn-danger btn-sm">Đăng xuất</a>
        </div>
    </div>
</nav>

<div class="container">
    <div class="row">
        <!-- User Management -->
        <div class="col-12">
            <div class="card">
                <div class="card-header bg-white py-3">
                    <h5 class="mb-0 fw-bold">Quản lý người dùng</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Tên đăng nhập</th>
                                    <th>Họ tên</th>
                                    <th>Vai trò</th>
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
                                    <td class="fw-bold">@<%= u.getUsername() %></td>
                                    <td><%= u.getFullName() %></td>
                                    <td><%= u.getRole() %></td>
                                    <td>
                                        <span class="status-badge <%= "ACTIVE".equals(u.getStatus()) ? (u.isBanned() ? "status-pending" : "status-active") : "status-banned" %>">
                                            <%= u.isBanned() ? "CẤM CHAT ĐẾN " + u.getBannedUntil().toString().substring(11, 16) : u.getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <button class="btn btn-outline-primary btn-sm rounded-pill px-3" 
                                                onclick="showUserDetail('<%= u.getId() %>', '<%= u.getUsername() %>', '<%= u.getFullName() %>', '<%= u.getRole() %>', '<%= u.getStatus() %>', '<%= u.isBanned() ? u.getBannedUntil().toString().substring(0, 16) : "Không" %>')">
                                            Xem chi tiết
                                        </button>
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
                                    <th>Nội dung báo cáo</th>
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
                                    <td><small><%= r.getReason() %></small></td>
                                    <td>
                                        <span class="status-badge <%= "PENDING".equals(r.getStatus()) ? "status-pending" : "status-active" %>">
                                            <%= r.getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if ("PENDING".equals(r.getStatus())) { %>
                                            <a href="admin?action=resolve_report&id=<%= r.getId() %>" class="btn btn-primary btn-sm rounded-pill">
                                                Đã xử lý
                                            </a>
                                        <% } %>
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
                        ID người dùng <span class="fw-bold" id="modalId">1</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        Vai trò <span class="badge bg-secondary" id="modalRole">USER</span>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showUserDetail(id, username, fullName, role, status, bannedUntil) {
        document.getElementById('modalId').innerText = id;
        document.getElementById('modalUsername').innerText = '@' + username;
        document.getElementById('modalFullName').innerText = fullName;
        document.getElementById('modalRole').innerText = role;
        document.getElementById('modalAvatar').innerText = username[0].toUpperCase();
        document.getElementById('modalBannedUntil').innerText = bannedUntil;
        
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
