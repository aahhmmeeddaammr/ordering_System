<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <meta name="description" content="E-Commerce Order System - Order Confirmation">
                <title>TechShop - Order Confirmed</title>
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

                    <div class="confirmation-icon">
                        ✓
                    </div>

                    <h1 class="confirmation-title">Order Confirmed!</h1>
                    <p class="confirmation-subtitle">
                        Thank you for your purchase. Your order has been received and is being processed.
                    </p>


                    <div class="order-details">
                        <div class="detail-card">
                            <div class="detail-label">Order ID</div>
                            <div class="detail-value">#${orderId}</div>
                        </div>
                        <div class="detail-card">
                            <div class="detail-label">Customer</div>
                            <div class="detail-value">${customerName}</div>
                        </div>
                        <div class="detail-card">
                            <div class="detail-label">Email</div>
                            <div class="detail-value">${customerEmail}</div>
                        </div>
                        <div class="detail-card">
                            <div class="detail-label">Total Amount</div>
                            <div class="detail-value" style="color: #667eea;">$
                                <fmt:formatNumber value="${finalTotal}" pattern="0.00" />
                            </div>
                        </div>
                    </div>


                    <div class="card" style="max-width: 800px; margin: 0 auto 32px;">
                        <c:choose>
                            <c:when test="${notificationSent}">
                                <div class="alert alert-success" style="margin: 0;">
                                    ✓ Order confirmation email has been sent to ${customerEmail}
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-warning" style="margin: 0;">
                                    ⚠️ We couldn't send the confirmation email. Your order was still placed
                                    successfully.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>


                    <div class="card" style="max-width: 800px; margin: 0 auto 32px;">
                        <div class="card-header">
                            <h2 class="card-title">📦 Order Items</h2>
                        </div>
                        <div id="orderItemsTable">
                        </div>
                    </div>


                    <div class="card" style="max-width: 800px; margin: 0 auto 32px;">
                        <div class="card-header">
                            <h2 class="card-title">💰 Pricing Details</h2>
                        </div>
                        <div id="pricingBreakdown">
                            <div class="summary-row total">
                                <span>Total Amount</span>
                                <span style="color: #667eea;">$
                                    <fmt:formatNumber value="${finalTotal}" pattern="0.00" />
                                </span>
                            </div>
                        </div>
                    </div>


                    <div style="text-align: center; margin-top: 40px;">
                        <a href="${pageContext.request.contextPath}/products" class="btn btn-primary btn-lg"
                            onclick="clearCart()">
                            ← Continue Shopping
                        </a>
                    </div>
                </main>


                <footer class="footer">
                    <div class="container">
                        <p>© 2024 TechShop - E-Commerce Order Management System</p>
                        <p style="margin-top: 8px; font-size: 0.85rem;">SOA Microservices Project</p>
                    </div>
                </footer>


                <div id="serverData" style="display: none;">
                    <span id="orderIdData">
                        <c:out value="${orderId}" default="0" />
                    </span>
                    <span id="pricingResponseData">
                        <c:out value="${pricingResponse}" default="{}" />
                    </span>
                    <span id="finalTotalData">
                        <c:out value="${finalTotal}" default="0" />
                    </span>
                </div>

                <script>

                    var orderId = document.getElementById('orderIdData').textContent || '0';
                    var pricingResponseText = document.getElementById('pricingResponseData').textContent || '{}';
                    var serverFinalTotal = parseFloat(document.getElementById('finalTotalData').textContent) || 0;

                    var pricingResponse = {};
                    try {
                        pricingResponse = JSON.parse(pricingResponseText);
                    } catch (e) {
                        console.log('Could not parse pricing response');
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
                        return productIcons[name] || productIcons['default'];
                    }

                    function clearCart() {
                        localStorage.removeItem('cart');
                    }

                    function renderOrderItemsFromPricing() {
                        var container = document.getElementById('orderItemsTable');

                        if (pricingResponse.items && pricingResponse.items.length > 0) {
                            var html = '<table class="table"><thead><tr>';
                            html += '<th>Product</th><th>Quantity</th><th>Unit Price</th><th>Discount</th><th style="text-align: right;">Total</th>';
                            html += '</tr></thead><tbody>';

                            for (var i = 0; i < pricingResponse.items.length; i++) {
                                var item = pricingResponse.items[i];
                                html += '<tr>';
                                html += '<td><div style="display: flex; align-items: center; gap: 12px;">';
                                html += '<span style="font-size: 1.5rem;">' + getProductIcon(item.product_name) + '</span>';
                                html += '<span>' + item.product_name + '</span></div></td>';
                                html += '<td>' + item.quantity + '</td>';
                                html += '<td>$' + item.unit_price.toFixed(2) + '</td>';
                                html += '<td>';
                                if (item.discount_percentage > 0) {
                                    html += '<span class="badge badge-success">-' + item.discount_percentage + '%</span>';
                                } else {
                                    html += '-';
                                }
                                html += '</td>';
                                html += '<td style="text-align: right; font-weight: 600;">$' + item.item_total.toFixed(2) + '</td>';
                                html += '</tr>';
                            }

                            html += '</tbody></table>';
                            container.innerHTML = html;
                        } else {
                            container.innerHTML = '<p style="color: var(--text-secondary); padding: 20px;">Order items details unavailable.</p>';
                        }
                    }

                    function renderPricingBreakdown() {
                        var container = document.getElementById('pricingBreakdown');

                        if (pricingResponse.success) {
                            var html = '<div class="summary-row"><span>Subtotal</span><span>$' + pricingResponse.subtotal.toFixed(2) + '</span></div>';

                            if (pricingResponse.total_discount > 0) {
                                html += '<div class="summary-row discount"><span>Bulk Discount</span><span>-$' + pricingResponse.total_discount.toFixed(2) + '</span></div>';
                            }

                            html += '<div class="summary-row"><span>After Discount</span><span>$' + pricingResponse.after_discount.toFixed(2) + '</span></div>';
                            html += '<div class="summary-row"><span>Tax (' + pricingResponse.tax_rate + '% - ' + pricingResponse.region + ')</span><span>$' + pricingResponse.tax_amount.toFixed(2) + '</span></div>';
                            html += '<div class="summary-row total"><span>Final Total</span><span style="color: #667eea;">$' + pricingResponse.final_total.toFixed(2) + '</span></div>';

                            container.innerHTML = html;
                        }
                    }


                    document.addEventListener('DOMContentLoaded', function () {
                        clearCart();
                        renderOrderItemsFromPricing();
                        renderPricingBreakdown();
                    });
                </script>
            </body>

            </html>