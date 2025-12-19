<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="E-Commerce Order System - Checkout">
    <title>TechShop - Checkout</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <div class="header-content">
                <div class="logo">
                    <span class="logo-icon">🛒</span>
                    <span>TechShop</span>
                </div>
                <nav class="nav">
                    <a href="${pageContext.request.contextPath}/products" class="nav-link">Products</a>
                    <a href="${pageContext.request.contextPath}/checkout" class="nav-link active">Checkout</a>
                </nav>
                <a href="${pageContext.request.contextPath}/checkout" class="cart-badge" id="cartBadge">
                    🛒 Cart
                    <span class="cart-count" id="cartCount">0</span>
                </a>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="container">
        <h1 class="page-title">🛒 Checkout</h1>
        
        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ⚠️ ${error}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/submitOrder.jsp" method="POST" id="checkoutForm">
            <div class="checkout-layout">
                <!-- Left Column: Cart Items -->
                <div>
                    <div class="card">
                        <div class="card-header">
                            <h2 class="card-title">Your Cart</h2>
                        </div>
                        
                        <!-- Cart Items Container -->
                        <div id="cartItems">
                            <!-- Cart items will be rendered here -->
                        </div>
                        
                        <!-- Empty Cart State -->
                        <div class="empty-cart" id="emptyCart" style="display: none;">
                            <div class="empty-cart-icon">🛒</div>
                            <h3 class="empty-cart-title">Your cart is empty</h3>
                            <p class="empty-cart-text">Add some products to get started</p>
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">
                                Browse Products
                            </a>
                        </div>
                    </div>
                    
                    <!-- Customer Selection -->
                    <div class="card mt-3">
                        <div class="card-header">
                            <h2 class="card-title">👤 Customer Information</h2>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="customer_id">Select Customer</label>
                            <select name="customer_id" id="customer_id" class="form-control" required>
                                <option value="">-- Select a Customer --</option>
                            </select>
                        </div>
                        
                        <div id="customerDetails" style="display: none;">
                            <div class="detail-card">
                                <div class="detail-label">Email</div>
                                <div class="detail-value" id="customerEmail">-</div>
                            </div>
                            <div class="detail-card mt-2">
                                <div class="detail-label">Loyalty Points</div>
                                <div class="detail-value" id="customerPoints">-</div>
                            </div>
                        </div>
                        
                        <div class="form-group mt-3">
                            <label class="form-label" for="region">Tax Region</label>
                            <select name="region" id="region" class="form-control">
                                <option value="Egypt">Egypt (14% Tax)</option>
                                <option value="UAE">UAE (5% Tax)</option>
                                <option value="Saudi Arabia">Saudi Arabia (15% Tax)</option>
                                <option value="Global">Global (10% Tax)</option>
                            </select>
                        </div>
                    </div>
                </div>
                
                <!-- Right Column: Order Summary -->
                <div>
                    <div class="card order-summary">
                        <div class="card-header">
                            <h2 class="card-title">📋 Order Summary</h2>
                        </div>
                        
                        <div id="summaryItems">
                            <!-- Summary items will be rendered here -->
                        </div>
                        
                        <div class="summary-row">
                            <span>Subtotal</span>
                            <span id="subtotal">$0.00</span>
                        </div>
                        <div class="summary-row discount" id="discountRow" style="display: none;">
                            <span>Discount</span>
                            <span id="discount">-$0.00</span>
                        </div>
                        <div class="summary-row">
                            <span>Tax (<span id="taxRate">14</span>%)</span>
                            <span id="taxAmount">$0.00</span>
                        </div>
                        <div class="summary-row total">
                            <span>Total</span>
                            <span id="finalTotal">$0.00</span>
                        </div>
                        
                        <input type="hidden" name="total_amount" id="totalAmountInput" value="0">
                        
                        <button type="submit" class="btn btn-success btn-block btn-lg mt-3" id="submitBtn" disabled>
                            ✓ Place Order
                        </button>
                        
                        <div id="loadingSpinner" style="display: none; text-align: center; margin-top: 20px;">
                            <div class="spinner" style="margin: 0 auto;"></div>
                            <p style="margin-top: 10px; color: var(--text-secondary);">Calculating prices...</p>
                        </div>
                    </div>
                    
                    <div class="card mt-3">
                        <div class="alert alert-info" style="margin: 0;">
                            ℹ️ Bulk discounts are applied automatically based on quantity.
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </main>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <p>© 2024 TechShop - E-Commerce Order Management System</p>
            <p style="margin-top: 8px; font-size: 0.85rem;">SOA Microservices Project</p>
        </div>
    </footer>

    <!-- Hidden data elements for JavaScript -->
    <div id="customersDataContainer" style="display: none;"><c:out value="${customersJson}" default="[]" escapeXml="false" /></div>
    <div id="productsDataContainer" style="display: none;"><c:out value="${productsJson}" default="[]" escapeXml="false" /></div>
    <div id="contextPathContainer" style="display: none;">${pageContext.request.contextPath}</div>

    <script>
        // Parse data from hidden elements
        var customersDataText = document.getElementById('customersDataContainer').textContent || '[]';
        var productsDataText = document.getElementById('productsDataContainer').textContent || '[]';
        var contextPath = document.getElementById('contextPathContainer').textContent || '';
        
        var customersData = [];
        var productsData = [];
        
        try {
            customersData = JSON.parse(customersDataText);
        } catch(e) {
            console.log('Could not parse customers data');
            customersData = [];
        }
        
        try {
            productsData = JSON.parse(productsDataText);
        } catch(e) {
            console.log('Could not parse products data');
            productsData = [];
        }
        
        // Cart from localStorage
        var cart = [];
        try {
            cart = JSON.parse(localStorage.getItem('cart') || '[]');
        } catch(e) {
            cart = [];
        }
        
        // Product icon mapping
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
        
        function renderCustomers() {
            var select = document.getElementById('customer_id');
            
            for (var i = 0; i < customersData.length; i++) {
                var customer = customersData[i];
                var option = document.createElement('option');
                option.value = customer.customer_id;
                option.textContent = customer.name + ' (' + customer.email + ')';
                option.setAttribute('data-email', customer.email);
                option.setAttribute('data-points', customer.loyalty_points);
                select.appendChild(option);
            }
            
            select.addEventListener('change', function() {
                var selected = this.options[this.selectedIndex];
                var details = document.getElementById('customerDetails');
                
                if (this.value) {
                    details.style.display = 'block';
                    document.getElementById('customerEmail').textContent = selected.getAttribute('data-email') || '-';
                    document.getElementById('customerPoints').textContent = selected.getAttribute('data-points') + ' points';
                    validateForm();
                } else {
                    details.style.display = 'none';
                    validateForm();
                }
            });
        }
        
        function updateQuantity(productId, delta) {
            for (var i = 0; i < cart.length; i++) {
                if (cart[i].product_id === productId) {
                    cart[i].quantity = Math.max(1, cart[i].quantity + delta);
                    break;
                }
            }
            localStorage.setItem('cart', JSON.stringify(cart));
            renderCart();
            calculatePricing();
        }
        
        function removeFromCart(productId) {
            var newCart = [];
            for (var i = 0; i < cart.length; i++) {
                if (cart[i].product_id !== productId) {
                    newCart.push(cart[i]);
                }
            }
            cart = newCart;
            localStorage.setItem('cart', JSON.stringify(cart));
            renderCart();
            calculatePricing();
        }
        
        function renderCart() {
            var container = document.getElementById('cartItems');
            var emptyCart = document.getElementById('emptyCart');
            
            updateCartBadge();
            
            if (cart.length === 0) {
                container.style.display = 'none';
                emptyCart.style.display = 'block';
                document.getElementById('submitBtn').disabled = true;
                return;
            }
            
            container.style.display = 'block';
            emptyCart.style.display = 'none';
            
            var html = '';
            for (var i = 0; i < cart.length; i++) {
                var item = cart[i];
                html += '<div class="cart-item">';
                html += '<div class="cart-item-image">' + getProductIcon(item.product_name) + '</div>';
                html += '<div class="cart-item-details">';
                html += '<div class="cart-item-name">' + item.product_name + '</div>';
                html += '<div class="cart-item-price">$' + item.unit_price.toFixed(2) + '</div>';
                html += '<input type="hidden" name="product_id" value="' + item.product_id + '">';
                html += '<input type="hidden" name="quantity" value="' + item.quantity + '">';
                html += '</div>';
                html += '<div class="quantity-input">';
                html += '<button type="button" class="quantity-btn" onclick="updateQuantity(' + item.product_id + ', -1)">−</button>';
                html += '<input type="text" class="quantity-value" value="' + item.quantity + '" readonly>';
                html += '<button type="button" class="quantity-btn" onclick="updateQuantity(' + item.product_id + ', 1)">+</button>';
                html += '</div>';
                html += '<button type="button" class="cart-item-remove" onclick="removeFromCart(' + item.product_id + ')" title="Remove">✕</button>';
                html += '</div>';
            }
            
            container.innerHTML = html;
            validateForm();
        }
        
        function calculatePricing() {
            if (cart.length === 0) {
                document.getElementById('subtotal').textContent = '$0.00';
                document.getElementById('taxAmount').textContent = '$0.00';
                document.getElementById('finalTotal').textContent = '$0.00';
                document.getElementById('totalAmountInput').value = '0';
                return;
            }
            
            var region = document.getElementById('region').value;
            var spinner = document.getElementById('loadingSpinner');
            
            spinner.style.display = 'block';
            
            var productsForPricing = [];
            for (var i = 0; i < cart.length; i++) {
                productsForPricing.push({
                    product_id: cart[i].product_id,
                    quantity: cart[i].quantity
                });
            }
            
            fetch(contextPath + '/api/pricing', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    products: productsForPricing,
                    region: region
                })
            })
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                if (data.success) {
                    document.getElementById('subtotal').textContent = '$' + data.subtotal.toFixed(2);
                    
                    if (data.total_discount > 0) {
                        document.getElementById('discountRow').style.display = 'flex';
                        document.getElementById('discount').textContent = '-$' + data.total_discount.toFixed(2);
                    } else {
                        document.getElementById('discountRow').style.display = 'none';
                    }
                    
                    document.getElementById('taxRate').textContent = data.tax_rate;
                    document.getElementById('taxAmount').textContent = '$' + data.tax_amount.toFixed(2);
                    document.getElementById('finalTotal').textContent = '$' + data.final_total.toFixed(2);
                    document.getElementById('totalAmountInput').value = data.final_total;
                    
                    // Render summary items
                    if (data.items) {
                        var summaryItems = document.getElementById('summaryItems');
                        var html = '';
                        for (var i = 0; i < data.items.length; i++) {
                            var item = data.items[i];
                            html += '<div style="display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid var(--border-color);">';
                            html += '<span style="color: var(--text-secondary);">';
                            html += item.product_name + ' × ' + item.quantity;
                            if (item.discount_percentage > 0) {
                                html += ' <span class="badge badge-success" style="margin-left: 8px;">-' + item.discount_percentage + '%</span>';
                            }
                            html += '</span>';
                            html += '<span>$' + item.item_total.toFixed(2) + '</span>';
                            html += '</div>';
                        }
                        summaryItems.innerHTML = html;
                    }
                } else {
                    console.error('Pricing error:', data.error);
                    calculateLocalPricing();
                }
                spinner.style.display = 'none';
            })
            .catch(function(error) {
                console.error('Failed to fetch pricing:', error);
                calculateLocalPricing();
                spinner.style.display = 'none';
            });
        }
        
        function calculateLocalPricing() {
            var subtotal = 0;
            for (var i = 0; i < cart.length; i++) {
                subtotal += cart[i].unit_price * cart[i].quantity;
            }
            
            var taxRates = { 'Egypt': 14, 'UAE': 5, 'Saudi Arabia': 15, 'Global': 10 };
            var region = document.getElementById('region').value;
            var taxRate = taxRates[region] || 14;
            var tax = subtotal * (taxRate / 100);
            var total = subtotal + tax;
            
            document.getElementById('subtotal').textContent = '$' + subtotal.toFixed(2);
            document.getElementById('taxRate').textContent = taxRate;
            document.getElementById('taxAmount').textContent = '$' + tax.toFixed(2);
            document.getElementById('finalTotal').textContent = '$' + total.toFixed(2);
            document.getElementById('totalAmountInput').value = total.toFixed(2);
        }
        
        function validateForm() {
            var customerId = document.getElementById('customer_id').value;
            var submitBtn = document.getElementById('submitBtn');
            
            if (customerId && cart.length > 0) {
                submitBtn.disabled = false;
            } else {
                submitBtn.disabled = true;
            }
        }
        
        // Initialize when DOM is ready
        document.addEventListener('DOMContentLoaded', function() {
            renderCustomers();
            renderCart();
            calculatePricing();
            
            document.getElementById('region').addEventListener('change', calculatePricing);
        });
    </script>
</body>
</html>
