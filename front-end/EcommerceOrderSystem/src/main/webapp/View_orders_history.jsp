<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="E-Commerce Order System - Order History">
    <title>TechShop - Order History</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .order-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            margin-bottom: 24px;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .order-card:hover {
            border-color: rgba(102, 126, 234, 0.5);
        }
        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 24px;
            background: var(--bg-input);
            flex-wrap: wrap;
            gap: 16px;
        }
        .order-header-left {
            display: flex;
            align-items: center;
            gap: 24px;
            flex-wrap: wrap;
        }
        .order-id {
            font-size: 1.25rem;
            font-weight: 700;
            color: #667eea;
        }
        .order-date {
            color: var(--text-secondary);
        }
        .order-status {
            padding: 6px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.85rem;
            text-transform: capitalize;
        }
        .order-status.pending {
            background: rgba(242, 153, 74, 0.2);
            color: #f2c94c;
        }
        .order-status.completed, .order-status.delivered {
            background: rgba(17, 153, 142, 0.2);
            color: #38ef7d;
        }
        .order-status.cancelled {
            background: rgba(235, 51, 73, 0.2);
            color: #f45c43;
        }
        .order-status.processing {
            background: rgba(102, 126, 234, 0.2);
            color: #667eea;
        }
        .order-body {
            padding: 24px;
        }
        .order-items {
            margin-bottom: 16px;
        }
        .order-item-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid var(--border-color);
        }
        .order-item-row:last-child {
            border-bottom: none;
        }
        .order-item-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .order-item-icon {
            font-size: 1.5rem;
        }
        .order-total {
            display: flex;
            justify-content: flex-end;
            padding-top: 16px;
            border-top: 1px solid var(--border-color);
        }
        .order-total-label {
            color: var(--text-secondary);
            margin-right: 16px;
        }
        .order-total-value {
            font-size: 1.25rem;
            font-weight: 700;
            color: #667eea;
        }
        .toggle-details {
            background: transparent;
            border: 1px solid var(--border-color);
            color: var(--text-secondary);
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.2s ease;
        }
        .toggle-details:hover {
            border-color: #667eea;
            color: var(--text-primary);
        }
    </style>
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
                    <a href="${pageContext.request.contextPath}/profile" class="nav-link">Profile</a>
                    <a href="${pageContext.request.contextPath}/orders" class="nav-link active">Order History</a>
                </nav>
                <a href="${pageContext.request.contextPath}/checkout" class="cart-badge">
                    🛒 Cart
                    <span class="cart-count">0</span>
                </a>
            </div>
        </div>
    </header>

    
    <main class="container" style="padding: 60px 24px;">
        <h1 class="page-title">📋 Order History</h1>
        
        
        <div class="alert alert-info" style="max-width: 800px;">
            👤 Viewing orders for: <strong>${customerName}</strong> (Customer #${customerId})
        </div>
        
        
        <c:if test="${not empty error}">
            <div class="alert alert-error" style="max-width: 800px;">
                ⚠️ ${error}
            </div>
        </c:if>
        
        
        <c:if test="${orderCount > 0}">
            <div style="color: var(--text-secondary); margin-bottom: 24px;">
                Found <strong>${orderCount}</strong> order(s)
            </div>
        </c:if>
        
        
        <div id="ordersContainer" style="max-width: 800px;">
            
        </div>
        
        
        <div id="emptyState" style="display: none; max-width: 800px;">
            <div class="empty-cart">
                <div class="empty-cart-icon">📦</div>
                <h3 class="empty-cart-title">No Orders Yet</h3>
                <p class="empty-cart-text">You haven't placed any orders yet. Start shopping!</p>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">
                    🛒 Browse Products
                </a>
            </div>
        </div>
        
        
        <div class="card" style="max-width: 800px; margin-top: 32px;">
            <div class="card-header">
                <h2 class="card-title">🔄 Switch Customer (Demo)</h2>
            </div>
            <form action="${pageContext.request.contextPath}/orders" method="GET">
                <div class="form-group" style="margin-bottom: 16px;">
                    <label class="form-label" for="customer_id">Select Customer</label>
                    <select name="customer_id" id="customer_id" class="form-control">
                        <option value="1" ${customerId == 1 ? 'selected' : ''}>Ahmed Hassan</option>
                        <option value="2" ${customerId == 2 ? 'selected' : ''}>Sara Mohamed</option>
                        <option value="3" ${customerId == 3 ? 'selected' : ''}>Omar Ali</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-secondary">
                    View Orders
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
    
    
    <div id="ordersDataContainer" style="display: none;"><c:out value="${ordersJson}" default="[]" escapeXml="false" /></div>

    <script>
        
        var ordersDataText = document.getElementById('ordersDataContainer').textContent || '[]';
        var ordersData = [];
        try {
            ordersData = JSON.parse(ordersDataText);
        } catch(e) {
            console.log('Could not parse orders data');
            ordersData = [];
        }
        
        
        var productIcons = {
            'laptop': '💻',
            'mouse': '🖱️',
            'keyboard': '⌨️',
            'monitor': '🖥️',
            'headphones': '🎧',
            'default': '📦'
        };
        
        function getProductIcon(productName) {
            if (!productName) return productIcons['default'];
            var name = productName.toLowerCase();
            var keys = Object.keys(productIcons);
            for (var i = 0; i < keys.length; i++) {
                var key = keys[i];
                if (name.indexOf(key) !== -1) {
                    return productIcons[key];
                }
            }
            return productIcons['default'];
        }
        
        function getStatusClass(status) {
            if (!status) return '';
            status = status.toLowerCase();
            if (status === 'pending') return 'pending';
            if (status === 'completed' || status === 'delivered') return 'completed';
            if (status === 'cancelled') return 'cancelled';
            if (status === 'processing') return 'processing';
            return 'pending';
        }
        
        function formatDate(dateStr) {
            if (!dateStr) return 'Unknown date';
            try {
                var date = new Date(dateStr);
                return date.toLocaleDateString('en-US', { 
                    year: 'numeric', 
                    month: 'long', 
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                });
            } catch(e) {
                return dateStr;
            }
        }
        
        function toggleDetails(orderId) {
            var body = document.getElementById('order-body-' + orderId);
            var btn = document.getElementById('toggle-btn-' + orderId);
            if (body.style.display === 'none') {
                body.style.display = 'block';
                btn.textContent = 'Hide Details';
            } else {
                body.style.display = 'none';
                btn.textContent = 'Show Details';
            }
        }
        
        function renderOrders() {
            var container = document.getElementById('ordersContainer');
            var emptyState = document.getElementById('emptyState');
            
            if (!ordersData || ordersData.length === 0) {
                container.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }
            
            var html = '';
            
            for (var i = 0; i < ordersData.length; i++) {
                var order = ordersData[i];
                var products = order.products || [];
                var totalAmount = order.total_amount || 0;
                
                html += '<div class="order-card">';
                html += '<div class="order-header" onclick="toggleDetails(' + order.order_id + ')" style="cursor: pointer;">';
                html += '<div class="order-header-left">';
                html += '<span class="order-id">Order #' + order.order_id + '</span>';
                html += '<span class="order-date">📅 ' + formatDate(order.order_date) + '</span>';
                html += '</div>';
                html += '<div style="display: flex; align-items: center; gap: 16px;">';
                html += '<span class="order-status ' + getStatusClass(order.status) + '">' + (order.status || 'pending') + '</span>';
                
                if (products.length > 0) {
                    html += '<span class="toggle-icon">▼</span>';
                }
                
                html += '</div></div>';
                
                
                html += '<div class="order-body" id="order-body-' + order.order_id + '" style="display: none;">';
                
                if (products.length > 0) {
                    html += '<div class="order-items">';
                    for (var j = 0; j < products.length; j++) {
                        var product = products[j];
                        var productName = product.product_name || ('Product #' + product.product_id);
                        var subtotal = product.subtotal || (product.unit_price * product.quantity) || 0;
                        
                        html += '<div class="order-item-row">';
                        html += '<div class="order-item-info">';
                        html += '<span class="order-item-icon">' + getProductIcon(productName) + '</span>';
                        html += '<span>' + productName + '</span>';
                        html += '<span style="color: var(--text-muted);">× ' + product.quantity + '</span>';
                        html += '</div>';
                        html += '<span style="font-weight: 600;">$' + subtotal.toFixed(2) + '</span>';
                        html += '</div>';
                    }
                    html += '</div>';
                }
                
                html += '<div class="order-total">';
                html += '<span class="order-total-label">Total:</span>';
                html += '<span class="order-total-value">$' + totalAmount.toFixed(2) + '</span>';
                html += '</div>';
                html += '</div>';
                
                html += '</div>';
            }
            
            container.innerHTML = html;
        }
        
        
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
        
        document.addEventListener('DOMContentLoaded', function() {
            renderOrders();
            updateCartBadge();
        });
    </script>
</body>
</html>
