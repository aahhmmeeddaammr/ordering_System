<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.ecommerce.ecommerceordersystem.HttpUtil" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(request.getContextPath() + "/checkout");
        return;
    }

    Gson gson = new Gson();
    
    
    String customerId = request.getParameter("customer_id");
    String[] productIds = request.getParameterValues("product_id");
    String[] quantities = request.getParameterValues("quantity");
    String totalAmount = request.getParameter("total_amount");
    String region = request.getParameter("region");
    
    
    if (customerId == null || customerId.isEmpty()) {
        request.setAttribute("error", "Please select a customer");
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
        return;
    }
    
    if (productIds == null || productIds.length == 0) {
        request.setAttribute("error", "Please select at least one product");
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
        return;
    }
    
    
    JsonArray products = new JsonArray();
    JsonArray productDetails = new JsonArray();
    
    for (int i = 0; i < productIds.length; i++) {
        if (productIds[i] != null && !productIds[i].isEmpty()) {
            int qty = 1;
            if (quantities != null && i < quantities.length && quantities[i] != null) {
                try {
                    qty = Integer.parseInt(quantities[i]);
                } catch (NumberFormatException e) {
                    qty = 1;
                }
            }
            
            if (qty > 0) {
                int productId = Integer.parseInt(productIds[i]);
                JsonObject product = new JsonObject();
                product.addProperty("product_id", productId);
                product.addProperty("quantity", qty);
                products.add(product);
                
                
                try {
                    String stockResponse = HttpUtil.sendGet(
                            HttpUtil.INVENTORY_SERVICE + "/api/inventory/check/" + productId
                    );
                    JsonObject stockJson = gson.fromJson(stockResponse, JsonObject.class);
                    
                    if (stockJson.has("success") && stockJson.get("success").getAsBoolean()) {
                        int availableQty = stockJson.has("quantity_available") ? 
                                stockJson.get("quantity_available").getAsInt() : 0;
                        
                        
                        if (qty > availableQty) {
                            String productName = stockJson.has("product_name") ? 
                                    stockJson.get("product_name").getAsString() : "Product #" + productId;
                            request.setAttribute("error", 
                                    "Insufficient stock for " + productName + ". Available: " + availableQty + ", Requested: " + qty);
                            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
                            return;
                        }
                        
                        JsonObject detail = new JsonObject();
                        detail.addProperty("product_id", productId);
                        detail.addProperty("product_name", stockJson.has("product_name") ? 
                                stockJson.get("product_name").getAsString() : "Product #" + productId);
                        detail.addProperty("unit_price", stockJson.has("unit_price") ? 
                                stockJson.get("unit_price").getAsDouble() : 0);
                        detail.addProperty("quantity", qty);
                        productDetails.add(detail);
                    }
                } catch (Exception e) {
                    
                }
            }
        }
    }
    
    if (products.isEmpty()) {
        request.setAttribute("error", "Please add products to your cart");
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
        return;
    }
    
    
    String customerName = "Unknown";
    String customerEmail = "";
    try {
        String customerResponse = HttpUtil.sendGet(
                HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId
        );
        JsonObject customerJson = gson.fromJson(customerResponse, JsonObject.class);
        if (customerJson.has("success") && customerJson.get("success").getAsBoolean()) {
            customerName = customerJson.has("name") ? customerJson.get("name").getAsString() : "Unknown";
            customerEmail = customerJson.has("email") ? customerJson.get("email").getAsString() : "";
        }
    } catch (Exception e) {
        
    }
    
    
    double finalTotal = 0;
    double subtotal = 0;
    double taxAmount = 0;
    double taxRate = 14;
    double discount = 0;
    JsonObject pricingResponse = new JsonObject();
    
    try {
        JsonObject pricingRequest = new JsonObject();
        pricingRequest.add("products", products);
        pricingRequest.addProperty("region", region != null ? region : "Egypt");
        
        String pricingResponseStr = HttpUtil.sendPost(
                HttpUtil.PRICING_SERVICE + "/api/pricing/calculate",
                gson.toJson(pricingRequest)
        );
        pricingResponse = gson.fromJson(pricingResponseStr, JsonObject.class);
        
        if (pricingResponse.has("success") && pricingResponse.get("success").getAsBoolean()) {
            finalTotal = pricingResponse.get("final_total").getAsDouble();
            subtotal = pricingResponse.has("subtotal") ? pricingResponse.get("subtotal").getAsDouble() : finalTotal;
            taxAmount = pricingResponse.has("tax_amount") ? pricingResponse.get("tax_amount").getAsDouble() : 0;
            taxRate = pricingResponse.has("tax_rate") ? pricingResponse.get("tax_rate").getAsDouble() : 14;
            discount = pricingResponse.has("total_discount") ? pricingResponse.get("total_discount").getAsDouble() : 0;
        }
    } catch (Exception e) {
        if (totalAmount != null && !totalAmount.isEmpty()) {
            finalTotal = Double.parseDouble(totalAmount);
        }
    }
    
    
    request.setAttribute("customerId", customerId);
    request.setAttribute("customerName", customerName);
    request.setAttribute("customerEmail", customerEmail);
    request.setAttribute("region", region != null ? region : "Egypt");
    request.setAttribute("products", products.toString());
    request.setAttribute("productDetails", productDetails.toString());
    request.setAttribute("subtotal", subtotal);
    request.setAttribute("discount", discount);
    request.setAttribute("taxRate", taxRate);
    request.setAttribute("taxAmount", taxAmount);
    request.setAttribute("finalTotal", finalTotal);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="E-Commerce Order System - Order Preview">
    <title>TechShop - Confirm Order</title>
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
                    <a href="${pageContext.request.contextPath}/profile" class="nav-link">Profile</a>
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
        <h1 class="page-title">📋 Confirm Your Order</h1>
        
        <div class="alert alert-warning" style="max-width: 800px;">
            ⚠️ Please review your order details before confirming.
        </div>
        
        
        <div class="card" style="max-width: 800px; margin-bottom: 24px;">
            <div class="card-header">
                <h2 class="card-title">👤 Customer Information</h2>
            </div>
            <div class="order-details" style="margin-top: 0;">
                <div class="detail-card">
                    <div class="detail-label">Customer</div>
                    <div class="detail-value">${customerName}</div>
                </div>
                <div class="detail-card">
                    <div class="detail-label">Email</div>
                    <div class="detail-value">${customerEmail}</div>
                </div>
                <div class="detail-card">
                    <div class="detail-label">Tax Region</div>
                    <div class="detail-value">${region}</div>
                </div>
            </div>
        </div>
        
        
        <div class="card" style="max-width: 800px; margin-bottom: 24px;">
            <div class="card-header">
                <h2 class="card-title">📦 Order Items</h2>
            </div>
            <div id="orderItems">
                
            </div>
        </div>
        
        
        <div class="card" style="max-width: 800px; margin-bottom: 32px;">
            <div class="card-header">
                <h2 class="card-title">💰 Price Summary</h2>
            </div>
            <div class="summary-row">
                <span>Subtotal</span>
                <span>$<%= String.format("%.2f", subtotal) %></span>
            </div>
            <% if (discount > 0) { %>
            <div class="summary-row discount">
                <span>Discount</span>
                <span>-$<%= String.format("%.2f", discount) %></span>
            </div>
            <% } %>
            <div class="summary-row">
                <span>Tax (<%= String.format("%.0f", taxRate) %>%)</span>
                <span>$<%= String.format("%.2f", taxAmount) %></span>
            </div>
            <div class="summary-row total">
                <span>Total</span>
                <span style="color: #667eea;">$<%= String.format("%.2f", finalTotal) %></span>
            </div>
        </div>
        
        
        <div style="max-width: 800px; display: flex; gap: 16px; flex-wrap: wrap;">
            <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary btn-lg" style="flex: 1;">
                ✕ Cancel Order
            </a>
            <form action="${pageContext.request.contextPath}/submitOrder.jsp" method="POST" style="flex: 1;" id="confirmForm">
                <input type="hidden" name="customer_id" value="${customerId}">
                <input type="hidden" name="region" value="${region}">
                <input type="hidden" name="total_amount" value="<%= finalTotal %>">
                <div id="hiddenProductInputs"></div>
                <button type="submit" class="btn btn-success btn-lg btn-block">
                    ✓ Confirm Order
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
    
    
    <div id="productsData" style="display: none;"><%= products.toString() %></div>
    <div id="productDetailsData" style="display: none;"><%= productDetails.toString() %></div>
    
    <script>
        var products = [];
        var productDetails = [];
        
        try {
            products = JSON.parse(document.getElementById('productsData').textContent || '[]');
            productDetails = JSON.parse(document.getElementById('productDetailsData').textContent || '[]');
        } catch(e) {
            console.log('Could not parse data');
        }
        
        var productIcons = {
            'laptop': '💻', 'mouse': '🖱️', 'keyboard': '⌨️',
            'monitor': '🖥️', 'headphones': '🎧', 'default': '📦'
        };
        
        function getProductIcon(name) {
            if (!name) return productIcons['default'];
            name = name.toLowerCase();
            for (var key in productIcons) {
                if (name.indexOf(key) !== -1) return productIcons[key];
            }
            return productIcons['default'];
        }
        
        
        function renderOrderItems() {
            var container = document.getElementById('orderItems');
            var html = '';
            
            for (var i = 0; i < productDetails.length; i++) {
                var p = productDetails[i];
                var subtotal = p.unit_price * p.quantity;
                
                html += '<div class="cart-item">';
                html += '<div class="cart-item-image">' + getProductIcon(p.product_name) + '</div>';
                html += '<div class="cart-item-details">';
                html += '<div class="cart-item-name">' + p.product_name + '</div>';
                html += '<div class="cart-item-price">$' + p.unit_price.toFixed(2) + ' × ' + p.quantity + '</div>';
                html += '</div>';
                html += '<div style="font-weight: 700; color: #667eea;">$' + subtotal.toFixed(2) + '</div>';
                html += '</div>';
            }
            
            container.innerHTML = html;
        }
        
        
        function addHiddenInputs() {
            var container = document.getElementById('hiddenProductInputs');
            var html = '';
            
            for (var i = 0; i < products.length; i++) {
                html += '<input type="hidden" name="product_id" value="' + products[i].product_id + '">';
                html += '<input type="hidden" name="quantity" value="' + products[i].quantity + '">';
            }
            
            container.innerHTML = html;
        }
        
        
        function updateCartBadge() {
            var cart = [];
            try { cart = JSON.parse(localStorage.getItem('cart') || '[]'); } catch(e) {}
            var total = 0;
            for (var i = 0; i < cart.length; i++) total += cart[i].quantity;
            var badge = document.querySelector('.cart-count');
            if (badge) badge.textContent = total;
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            renderOrderItems();
            addHiddenInputs();
            updateCartBadge();
        });
    </script>
</body>
</html>
