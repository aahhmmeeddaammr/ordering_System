<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Success - TechShop</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
    <header class="header">
        <div class="container" style="display: flex; justify-content: space-between; align-items: center; padding: 1rem 0;">
            <div class="logo">
                <a href="${pageContext.request.contextPath}/" style="text-decoration: none; color: inherit; display: flex; align-items: center; gap: 0.5rem;">
                    <span class="logo-icon">🛒</span>
                    <span style="font-weight: 700; font-size: 1.5rem;">TechShop</span>
                </a>
            </div>
        </div>
    </header>

    <main class="container">
        <div class="card mt-4 text-center">
            <div class="confirmation-icon">✓</div>
            <h1 class="confirmation-title">Order Successfully Placed!</h1>
            <p class="confirmation-subtitle">Thank you for your purchase. Your order has been processed and a notification has been sent.</p>
            
            <div class="order-details mt-4">
                <div class="detail-card">
                    <div class="detail-label">Order ID</div>
                    <div class="detail-value">#${order_id}</div>
                </div>
                <div class="detail-card">
                    <div class="detail-label">Status</div>
                    <div class="detail-value">
                        <span class="badge badge-success">Processed</span>
                    </div>
                </div>
                <div class="detail-card">
                    <div class="detail-label">Total Amount</div>
                    <div class="detail-value">$${total_amount}</div>
                </div>
                <div class="detail-card">
                    <div class="detail-label">Order Date</div>
                    <div class="detail-value">Today</div>
                </div>
            </div>

            <div class="alert alert-success">
                ℹ️ Loyalty points have been updated in your profile!
            </div>

            <div class="mt-4">
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary btn-lg">
                    Return to Shop
                </a>
                <a href="${pageContext.request.contextPath}/ordersHistory?customer_id=1" class="btn btn-secondary btn-lg" style="margin-left: 1rem;">
                    View Order History
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        <div class="container">
            <p>© 2024 TechShop - SOA Microservices Project</p>
        </div>
    </footer>
</body>
</html>
