<%@page import="com.network.model.Report"%>
<%@page import="java.util.List"%>
<%@page import="com.network.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Report> reports = (List<Report>) request.getAttribute("reports");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Báo cáo vi phạm - SkyChat</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; font-family: 'Inter', sans-serif; }
        .sidebar { height: 100vh; background: #1e293b; color: white; padding: 2rem 1rem; }
        .nav-link { color: #94a3b8; border-radius: 10px; margin-bottom: 5px; }
        .nav-link:hover, .nav-link.active { background: #334155; color: white; }
        .card { border-radius: 15px; border: none; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
    </style>
</head>
<body>

<div class="container-fluid">
    <div class="row">
        <div class="col-md-2 sidebar">
            <h4 class="fw-bold mb-4 px-3">SkyChat Admin</h4>
            <nav class="nav flex-column">
                <a class="nav-link" href="admin"><i class="bi bi-people me-2"></i> Người dùng</a>
                <a class="nav-link active" href="admin?type=reports"><i class="bi bi-flag me-2"></i> Báo cáo</a>
                <a class="nav-link" href="chat.jsp"><i class="bi bi-chat me-2"></i> Vào Chat</a>
                <a class="nav-link mt-5" href="logout"><i class="bi bi-box-arrow-left me-2"></i> Đăng xuất</a>
            </nav>
        </div>
        <div class="col-md-10 p-5">
            <h2 class="fw-bold mb-4">Danh sách báo cáo vi phạm</h2>

            <div class="card p-4">
                <table class="table align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Người báo cáo</th>
                            <th>Người bị báo cáo</th>
                            <th>Nội dung tin nhắn</th>
                            <th>Lý do</th>
                            <th>Thời gian</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (reports != null) { for (Report r : reports) { %>
                        <tr>
                            <td><%= r.getReporterName() %></td>
                            <td class="fw-bold"><%= r.getReportedName() %></td>
                            <td class="text-muted italic">"<%= r.getMessageContent() != null ? r.getMessageContent() : "N/A" %>"</td>
                            <td><span class="text-danger"><%= r.getReason() %></span></td>
                            <td><%= r.getCreatedAt() %></td>
                            <td>
                                <% if ("PENDING".equals(r.getStatus())) { %>
                                    <span class="badge bg-warning">Chờ xử lý</span>
                                <% } else { %>
                                    <span class="badge bg-success">Đã giải quyết</span>
                                <% } %>
                            </td>
                        </tr>
                        <% }} %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

</body>
</html>
