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
    <!-- Header -->
    <header class="header">
        <div class="container" style="display: flex; justify-content: space-between; align-items: center; padding: 1rem 0;">
            <div class="logo">
                <a href="${pageContext.request.contextPath}/" style="text-decoration: none; color: inherit; display: flex; align-items: center; gap: 0.5rem;">
                    <span class="logo-icon">🛒</span>
                    <span style="font-weight: 700; font-size: 1.5rem;">TechShop</span>
                </a>
            </div>
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/products" class="nav-link active">Products</a>
                <a href="${pageContext.request.contextPath}/profile?customer_id=1" class="nav-link">Profile</a>
                <a href="${pageContext.request.contextPath}/ordersHistory?customer_id=1" class="nav-link">Orders History</a>
                <a href="${pageContext.request.contextPath}/checkout" class="nav-link">Checkout</a>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container">
            <h1 class="hero-title">Scenario-1: Product Selection</h1>
            <p class="hero-subtitle">Select the products you want to buy and click "Make Order".</p>
        </div>
    </section>

    <!-- Main Content -->
    <main class="container">
        <!-- Error Alert -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ⚠️ ${error}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/processOrder" method="POST">
            <!-- Product Grid -->
            <div class="product-grid" id="productGrid">
                <c:forEach var="product" items="${products}">
                    <c:if test="${product.getAsJsonObject().get('quantity_available').getAsInt() > 0}">
                        <div class="product-card">
                            <div class="product-image">
                                <c:choose>
                                    <c:when test="${product.getAsJsonObject().get('product_name').getAsString().toLowerCase().contains('laptop')}">💻</c:when>
                                    <c:when test="${product.getAsJsonObject().get('product_name').getAsString().toLowerCase().contains('mouse')}">🖱️</c:when>
                                    <c:when test="${product.getAsJsonObject().get('product_name').getAsString().toLowerCase().contains('keyboard')}">⌨️</c:when>
                                    <c:when test="${product.getAsJsonObject().get('product_name').getAsString().toLowerCase().contains('monitor')}">🖥️</c:when>
                                    <c:otherwise>📦</c:otherwise>
                                </c:choose>
                            </div>
                            <div class="product-content">
                                <h3 class="product-name">${product.getAsJsonObject().get('product_name').getAsString()}</h3>
                                <div class="product-price">$${product.getAsJsonObject().get('unit_price').getAsDouble()}</div>
                                <div class="product-stock available">
                                    ✓ ${product.getAsJsonObject().get('quantity_available').getAsInt()} in stock
                                </div>
                                
                                <div class="form-group" style="margin-top: 1rem;">
                                    <label class="flex items-center gap-2" style="cursor: pointer;">
                                        <input type="checkbox" name="selected_products" value="${product.getAsJsonObject().get('product_id').getAsInt()}" style="width: 20px; height: 20px;">
                                        <span>Select to buy</span>
                                    </label>
                                </div>
                                
                                <div class="form-group">
                                    <label class="form-label">Quantity:</label>
                                    <input type="number" name="quantity_${product.getAsJsonObject().get('product_id').getAsInt()}" value="1" min="1" max="${product.getAsJsonObject().get('quantity_available').getAsInt()}" class="form-control">
                                </div>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>

            <div style="text-align: center; margin-top: 2rem;">
                <button type="submit" class="btn btn-primary btn-lg" style="padding: 1rem 4rem;">
                    🚀 Make Order
                </button>
            </div>
        </form>

        <!-- Empty State -->
        <c:if test="${empty products}">
            <div class="empty-cart" id="emptyState">
                <div class="empty-cart-icon">📦</div>
                <h3 class="empty-cart-title">No Products Available</h3>
                <p class="empty-cart-text">Please check back later or contact support.</p>
            </div>
        </c:if>
    </main>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <p>© 2024 TechShop - SOA Microservices Project</p>
        </div>
    </footer>
</body>
</html>