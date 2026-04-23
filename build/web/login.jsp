<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Chat System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary: #c4b5fd;
            --primary-hover: #b19cd9;
            --primary-gradient: linear-gradient(135deg, #fbcfe8 0%, #ddd6fe 50%, #bfdbfe 100%);
            --bg: #fdf2f8;
        }
        body {
            background: linear-gradient(120deg, #fdf2f8 0%, #f5f3ff 100%);
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
        }
        .auth-card {
            background: white;
            padding: 2.5rem;
            border-radius: 1.5rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            width: 100%;
            max-width: 450px;
            transition: all 0.3s ease;
        }
        .brand {
            text-align: center;
            margin-bottom: 2rem;
        }
        .brand i {
            font-size: 3rem;
            color: var(--primary);
        }
        .brand h2 {
            font-weight: 800;
            color: #1e293b;
            margin-top: 1rem;
        }
        .form-label {
            font-weight: 600;
            color: #475569;
            font-size: 0.875rem;
        }
        .form-control {
            border-radius: 0.75rem;
            padding: 0.75rem 1rem;
            border: 1px solid #e2e8f0;
            transition: all 0.2s;
        }
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
        }
        .btn-primary {
            background: var(--primary-gradient);
            border: none;
            border-radius: 0.75rem;
            padding: 0.75rem;
            font-weight: 600;
            width: 100%;
            transition: all 0.2s;
            color: #4b2c20;
        }
        .btn-primary:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }
        .toggle-auth {
            text-align: center;
            margin-top: 1.5rem;
            color: #64748b;
            font-size: 0.875rem;
        }
        .toggle-auth a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }
        .alert {
            border-radius: 0.75rem;
            font-size: 0.875rem;
        }
        .hidden { display: none; }
    </style>
</head>
<body>

<div class="auth-card">
    <div class="brand">
        <i class="bi bi-chat-heart-fill"></i>
        <h2>SkyChat</h2>
        <p class="text-muted">Kết nối mọi lúc, mọi nơi</p>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger">
            <i class="bi bi-exclamation-circle me-2"></i> <%= request.getAttribute("error") %>
        </div>
    <% } %>
    <% if (request.getAttribute("message") != null) { %>
        <div class="alert alert-success">
            <i class="bi bi-check-circle me-2"></i> <%= request.getAttribute("message") %>
        </div>
    <% } %>

    <!-- Login Form -->
    <form id="loginForm" action="login" method="POST">
        <div class="mb-3">
            <label class="form-label">Tên đăng nhập</label>
            <input type="text" name="username" class="form-control" placeholder="Nhập username" required>
        </div>
        <div class="mb-4">
            <label class="form-label">Mật khẩu</label>
            <input type="password" name="password" class="form-control" placeholder="••••••••" required>
        </div>
        <button type="submit" class="btn btn-primary">Đăng nhập</button>
        <div class="toggle-auth">
            Chưa có tài khoản? <a href="#" onclick="toggleAuth()">Đăng ký ngay</a>
        </div>
    </form>

    <!-- Register Form -->
    <form id="registerForm" action="register" method="POST" class="hidden">
        <div class="mb-3">
            <label class="form-label">Tên đăng nhập</label>
            <input type="text" name="username" class="form-control" placeholder="Tên dùng để đăng nhập" required>
        </div>
        <div class="mb-3">
            <label class="form-label">Họ và tên</label>
            <input type="text" name="fullName" class="form-control" placeholder="Nguyễn Văn A" required>
        </div>
        <div class="mb-4">
            <label class="form-label">Mật khẩu</label>
            <input type="password" name="password" class="form-control" placeholder="••••••••" required>
        </div>
        <button type="submit" class="btn btn-primary">Tạo tài khoản</button>
        <div class="toggle-auth">
            Đã có tài khoản? <a href="#" onclick="toggleAuth()">Đăng nhập</a>
        </div>
    </form>
</div>

<script>
    function toggleAuth() {
        const loginForm = document.getElementById('loginForm');
        const registerForm = document.getElementById('registerForm');
        loginForm.classList.toggle('hidden');
        registerForm.classList.toggle('hidden');
        
        const title = document.querySelector('.brand p');
        if (loginForm.classList.contains('hidden')) {
            title.innerText = "Tham gia cộng đồng SkyChat";
        } else {
            title.innerText = "Kết nối mọi lúc, mọi nơi";
        }
    }
</script>

</body>
</html>
