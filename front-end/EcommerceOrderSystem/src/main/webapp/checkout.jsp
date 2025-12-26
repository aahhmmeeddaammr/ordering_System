<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechShop - Review Order</title>
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
        <h1 class="page-title">Scenario-1: Checkout & Review</h1>
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">⚠️ ${error}</div>
        </c:if>

        <div class="checkout-layout">
            <!-- Order Details -->
            <div>
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">📦 Selected Products</h2>
                    </div>
                    <div id="cartItems">
                        <c:forEach var="item" items="${selectedProducts}">
                            <div class="cart-item">
                                <div class="cart-item-image">📦</div>
                                <div class="cart-item-details">
                                    <div class="cart-item-name">${item.getAsJsonObject().get('product_name').getAsString()}</div>
                                    <div class="cart-item-price">$${item.getAsJsonObject().get('unit_price').getAsDouble()} each</div>
                                </div>
                                <div class="quantity-input">
                                    <span class="badge badge-info">${item.getAsJsonObject().get('quantity').getAsInt()} units</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div class="card mt-3">
                    <div class="card-header">
                        <h2 class="card-title">👤 Confirm Customer</h2>
                    </div>
                    <form action="${pageContext.request.contextPath}/confirmOrder" method="POST" id="confirmForm">
                        <input type="hidden" name="total_amount" value="${totalAmount}">
                        <input type="hidden" name="products_json" value='${selectedProducts}'>
                        
                        <div class="form-group">
                            <label class="form-label">Select Customer Identity:</label>
                            <select name="customer_id" class="form-control" required>
                                <option value="">-- Choose Customer --</option>
                                <c:forEach var="customer" items="${customers}">
                                    <option value="${customer.getAsJsonObject().get('customer_id').getAsInt()}">
                                        ${customer.getAsJsonObject().get('name').getAsString()} (${customer.getAsJsonObject().get('email').getAsString()})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary" style="flex: 1;">
                                ✕ Cancel & Go Back
                            </a>
                            <button type="submit" class="btn btn-success" style="flex: 2;">
                                ✓ Confirm & Place Order
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Order Summary -->
            <aside>
                <div class="card order-summary">
                    <div class="card-header">
                        <h2 class="card-title">📋 Payment Summary</h2>
                    </div>
                    
                    <div class="summary-row">
                        <span>Subtotal</span>
                        <span>$${pricingDetails.getAsJsonObject().get('subtotal').getAsDouble()}</span>
                    </div>
                    <c:if test="${pricingDetails.getAsJsonObject().get('total_discount').getAsDouble() > 0}">
                        <div class="summary-row discount">
                            <span>Bulk Discount</span>
                            <span>-$${pricingDetails.getAsJsonObject().get('total_discount').getAsDouble()}</span>
                        </div>
                    </c:if>
                    <div class="summary-row">
                        <span>Tax (${pricingDetails.getAsJsonObject().get('tax_rate').getAsInt()}%)</span>
                        <span>$${pricingDetails.getAsJsonObject().get('tax_amount').getAsDouble()}</span>
                    </div>
                    <div class="summary-row total">
                        <span>Total Due</span>
                        <span>$${pricingDetails.getAsJsonObject().get('final_total').getAsDouble()}</span>
                    </div>
                    
                    <div class="mt-3">
                        <div class="alert alert-info" style="font-size: 0.9rem;">
                            ℹ️ Prices calculated based on current inventory and region tax rules.
                        </div>
                    </div>
                </div>
            </aside>
        </div>
    </main>

    <footer class="footer">
        <div class="container">
            <p>© 2024 TechShop - SOA Microservices Project</p>
        </div>
    </footer>
</body>
</html>
