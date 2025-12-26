<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order History - TechShop</title>
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
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/products" class="nav-link">Products</a>
                <a href="${pageContext.request.contextPath}/profile?customer_id=1" class="nav-link">Profile</a>
                <a href="${pageContext.request.contextPath}/ordersHistory?customer_id=1" class="nav-link active">Orders History</a>
            </nav>
        </div>
    </header>

    <main class="container">
        <h1 class="page-title">Scenario-3: Order History</h1>
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">⚠️ ${error}</div>
        </c:if>

        <c:choose>
            <c:when test="${not empty orders}">
                <div class="product-grid" style="grid-template-columns: 1fr; gap: 2rem;">
                    <c:forEach var="order" items="${orders}">
                        <div class="card">
                            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                                <div>
                                    <h2 class="card-title">Order #${order.get('order_id').getAsInt()}</h2>
                                    <p style="color: var(--text-secondary); font-size: 0.9rem;">
                                        Placed on: ${order.has('timestamp') ? order.get('timestamp').getAsString() : 'Recent'}
                                    </p>
                                </div>
                                <div class="text-right">
                                    <div style="font-size: 1.5rem; font-weight: 700; color: #667eea;">
                                        $${order.get('total_amount').getAsDouble()}
                                    </div>
                                    <span class="badge badge-success">Completed</span>
                                </div>
                            </div>
                            
                            <div class="mt-3">
                                <h4 style="margin-bottom: 1rem; color: var(--text-muted);">Items Preview:</h4>
                                <div style="display: flex; flex-wrap: wrap; gap: 1rem;">
                                    <c:forEach var="item" items="${order.getAsJsonArray('items')}">
                                        <div class="detail-card" style="padding: 0.75rem 1rem; flex: 1; min-width: 200px;">
                                            <div style="display: flex; align-items: center; gap: 0.5rem;">
                                                <span>📦</span>
                                                <strong>${item.getAsJsonObject().get('product_name').getAsString()}</strong>
                                                <span class="badge badge-info" style="margin-left: auto;">x${item.getAsJsonObject().get('quantity').getAsInt()}</span>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-cart">
                    <div class="empty-cart-icon">📜</div>
                    <h3 class="empty-cart-title">No Orders Yet</h3>
                    <p class="empty-cart-text">You haven't placed any orders yet. Start shopping to see your history here!</p>
                    <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Go Shopping</a>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <footer class="footer">
        <div class="container">
            <p>© 2024 TechShop - SOA Microservices Project</p>
        </div>
    </footer>
</body>
</html>
