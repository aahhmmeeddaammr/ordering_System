<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="E-Commerce Order System - Browse our product catalog">
    <title>TechShop - Product Catalog</title>
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
                    <a href="${pageContext.request.contextPath}/products" class="nav-link active">Products</a>
                    <a href="${pageContext.request.contextPath}/checkout" class="nav-link">Checkout</a>
                    <a href="${pageContext.request.contextPath}/profile" class="nav-link">Profile</a>
                    <a href="${pageContext.request.contextPath}/orders" class="nav-link">Order History</a>
                </nav>
                <a href="${pageContext.request.contextPath}/checkout" class="cart-badge" id="cartBadge">
                    🛒 Cart
                    <span class="cart-count" id="cartCount">0</span>
                </a>
            </div>
        </div>
    </header>

    
    <section class="hero">
        <div class="container">
            <h1 class="hero-title">Premium Tech Products</h1>
            <p class="hero-subtitle">Discover our collection of high-quality electronics. Fast delivery, great prices, excellent service.</p>
        </div>
    </section>

    
    <main class="container">
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ⚠️ ${error}
            </div>
        </c:if>

        
        <div class="product-grid" id="productGrid">
            
        </div>

        
        <div class="empty-cart" id="emptyState" style="display: none;">
            <div class="empty-cart-icon">📦</div>
            <h3 class="empty-cart-title">No Products Available</h3>
            <p class="empty-cart-text">Please check back later or contact support.</p>
        </div>
    </main>

    
    <footer class="footer">
        <div class="container">
            <p>© 2024 TechShop - E-Commerce Order Management System</p>
            <p style="margin-top: 8px; font-size: 0.85rem;">SOA Microservices Project</p>
        </div>
    </footer>

    
    <div id="productsDataContainer" style="display: none;"><c:out value="${productsJson}" default="[]" escapeXml="false" /></div>

    <script>
        
        var productsDataText = document.getElementById('productsDataContainer').textContent || '[]';
        var productsData = [];
        try {
            productsData = JSON.parse(productsDataText);
        } catch(e) {
            console.log('Could not parse products data');
            productsData = [];
        }
        
        
        var cart = [];
        try {
            cart = JSON.parse(localStorage.getItem('cart') || '[]');
        } catch(e) {
            cart = [];
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
        
        function updateCartBadge() {
            var totalItems = 0;
            for (var i = 0; i < cart.length; i++) {
                totalItems += cart[i].quantity;
            }
            document.getElementById('cartCount').textContent = totalItems;
        }
        
        function addToCart(productId) {
            var product = null;
            for (var i = 0; i < productsData.length; i++) {
                if (productsData[i].product_id === productId) {
                    product = productsData[i];
                    break;
                }
            }
            
            if (!product) return;
            
            var existingItem = null;
            for (var i = 0; i < cart.length; i++) {
                if (cart[i].product_id === productId) {
                    existingItem = cart[i];
                    break;
                }
            }
            
            if (existingItem) {
                existingItem.quantity += 1;
            } else {
                cart.push({
                    product_id: product.product_id,
                    product_name: product.product_name,
                    unit_price: product.unit_price,
                    quantity: 1
                });
            }
            
            localStorage.setItem('cart', JSON.stringify(cart));
            updateCartBadge();
            
            
            showNotification('Added to cart: ' + product.product_name);
        }
        
        function showNotification(message) {
            
            var notification = document.createElement('div');
            notification.className = 'alert alert-success';
            notification.style.cssText = 'position: fixed; top: 100px; right: 20px; z-index: 1001; animation: slideIn 0.3s ease;';
            notification.innerHTML = '✓ ' + message;
            
            document.body.appendChild(notification);
            
            
            setTimeout(function() {
                notification.style.animation = 'fadeOut 0.3s ease';
                setTimeout(function() {
                    if (notification.parentNode) {
                        notification.parentNode.removeChild(notification);
                    }
                }, 300);
            }, 2000);
        }
        
        function renderProducts() {
            var grid = document.getElementById('productGrid');
            var emptyState = document.getElementById('emptyState');
            
            if (!productsData || productsData.length === 0) {
                grid.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }
            
            var html = '';
            for (var i = 0; i < productsData.length; i++) {
                var product = productsData[i];
                var isAvailable = product.status === 'available';
                
                html += '<div class="product-card">';
                html += '<div class="product-image">' + getProductIcon(product.product_name) + '</div>';
                html += '<div class="product-content">';
                html += '<h3 class="product-name">' + product.product_name + '</h3>';
                html += '<div class="product-price">$' + product.unit_price.toFixed(2) + '</div>';
                html += '<div class="product-stock ' + (isAvailable ? 'available' : 'out-of-stock') + '">';
                if (isAvailable) {
                    html += '✓ In Stock (' + product.quantity_available + ' available)';
                } else {
                    html += '✕ Out of Stock';
                }
                html += '</div>';
                html += '<button class="btn btn-primary btn-block" onclick="addToCart(' + product.product_id + ')"';
                if (!isAvailable) {
                    html += ' disabled style="opacity: 0.5; cursor: not-allowed;"';
                }
                html += '>';
                html += isAvailable ? '🛒 Add to Cart' : 'Out of Stock';
                html += '</button>';
                html += '</div></div>';
            }
            
            grid.innerHTML = html;
        }
        
        
        var style = document.createElement('style');
        style.textContent = '@keyframes slideIn { from { transform: translateX(100px); opacity: 0; } to { transform: translateX(0); opacity: 1; } } @keyframes fadeOut { from { opacity: 1; } to { opacity: 0; } }';
        document.head.appendChild(style);
        
        
        document.addEventListener('DOMContentLoaded', function() {
            renderProducts();
            updateCartBadge();
        });
    </script>
</body>
</html>