<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="E-Commerce Order System - Customer Profile">
    <title>TechShop - My Profile</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
    
    <header class="header">
        <div class="container">
            <div class="header-content">
                <div class="logo">
                    <span class="logo-icon">🛒</span>
                    <span>TechShop</span>
                </div>
                <nav class="nav">
                    <a href="${pageContext.request.contextPath}/products" class="nav-link">Products</a>
                    <a href="${pageContext.request.contextPath}/checkout" class="nav-link">Checkout</a>
                    <a href="${pageContext.request.contextPath}/profile" class="nav-link active">Profile</a>
                    <a href="${pageContext.request.contextPath}/orders" class="nav-link">Order History</a>
                </nav>
                <a href="${pageContext.request.contextPath}/checkout" class="cart-badge">
                    🛒 Cart
                    <span class="cart-count">0</span>
                </a>
            </div>
        </div>
    </header>

    
    <main class="container" style="padding: 60px 24px;">
        <h1 class="page-title">👤 My Profile</h1>
        
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ⚠️ ${error}
            </div>
        </c:if>
        
        
        <div class="order-details" style="max-width: 800px;">
            <div class="detail-card">
                <div class="detail-label">Customer ID</div>
                <div class="detail-value">#${customerId}</div>
            </div>
            <div class="detail-card">
                <div class="detail-label">Name</div>
                <div class="detail-value">${customerName}</div>
            </div>
            <div class="detail-card">
                <div class="detail-label">Email</div>
                <div class="detail-value">${customerEmail}</div>
            </div>
            <div class="detail-card">
                <div class="detail-label">Phone</div>
                <div class="detail-value">
                    <c:choose>
                        <c:when test="${not empty customerPhone}">${customerPhone}</c:when>
                        <c:otherwise>Not provided</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        
        
        <div class="card" style="max-width: 800px; margin-top: 32px;">
            <div class="card-header">
                <h2 class="card-title">🏆 Loyalty Program</h2>
            </div>
            <div style="display: flex; align-items: center; gap: 24px;">
                <div class="confirmation-icon" style="width: 80px; height: 80px; font-size: 2rem; margin: 0; background: var(--warning-gradient);">
                    ⭐
                </div>
                <div>
                    <div style="font-size: 2.5rem; font-weight: 700; color: #f2c94c;">
                        ${loyaltyPoints}
                    </div>
                    <div style="color: var(--text-secondary);">Loyalty Points</div>
                </div>
            </div>
            <div class="alert alert-info" style="margin-top: 24px; margin-bottom: 0;">
                ℹ️ Earn 1 loyalty point for every $10 spent. Points can be redeemed for discounts on future orders!
            </div>
        </div>
        
        
        <c:if test="${not empty createdAt}">
            <div class="card" style="max-width: 800px; margin-top: 32px;">
                <div style="display: flex; align-items: center; gap: 16px;">
                    <span style="font-size: 2rem;">📅</span>
                    <div>
                        <div style="color: var(--text-secondary); font-size: 0.85rem;">Member Since</div>
                        <div style="font-weight: 600;">${createdAt}</div>
                    </div>
                </div>
            </div>
        </c:if>
        
        
        <div class="card" style="max-width: 800px; margin-top: 32px;">
            <div class="card-header">
                <h2 class="card-title">🔗 Quick Links</h2>
            </div>
            <div style="display: flex; gap: 16px; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/orders?customer_id=${customerId}" class="btn btn-primary">
                    📋 View Order History
                </a>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary">
                    🛒 Continue Shopping
                </a>
            </div>
        </div>
        
        
        <div class="card" style="max-width: 800px; margin-top: 32px;">
            <div class="card-header">
                <h2 class="card-title">🔄 Switch Customer (Demo)</h2>
            </div>
            <form action="${pageContext.request.contextPath}/profile" method="GET">
                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label" for="customer_id">Select Customer</label>
                    <select name="customer_id" id="customer_id" class="form-control">
                        <option value="1" ${customerId == 1 ? 'selected' : ''}>Ahmed Hassan</option>
                        <option value="2" ${customerId == 2 ? 'selected' : ''}>Sara Mohamed</option>
                        <option value="3" ${customerId == 3 ? 'selected' : ''}>Omar Ali</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-secondary">
                    View Profile
                </button>
            </form>
        </div>
    </main>

    
    <footer class="footer">
        <div class="container">
            <p>© 2024 TechShop - E-Commerce Order Management System</p>
            <p style="margin-top: 8px; font-size: 0.85rem;">SOA Microservices Project</p>
        </div>
    </footer>
    
    <script>
        
        function updateCartBadge() {
            var cart = [];
            try {
                cart = JSON.parse(localStorage.getItem('cart') || '[]');
            } catch(e) {
                cart = [];
            }
            var totalItems = 0;
            for (var i = 0; i < cart.length; i++) {
                totalItems += cart[i].quantity;
            }
            var badge = document.querySelector('.cart-count');
            if (badge) {
                badge.textContent = totalItems;
            }
        }
        
        document.addEventListener('DOMContentLoaded', updateCartBadge);
    </script>
</body>
</html>
