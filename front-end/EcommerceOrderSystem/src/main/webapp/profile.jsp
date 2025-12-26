<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile - TechShop</title>
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
                <a href="${pageContext.request.contextPath}/profile?customer_id=1" class="nav-link active">Profile</a>
                <a href="${pageContext.request.contextPath}/ordersHistory?customer_id=1" class="nav-link">Orders History</a>
            </nav>
        </div>
    </header>

    <main class="container">
        <h1 class="page-title">Scenario-2: Customer Profile</h1>
        
        <div class="card" style="max-width: 800px; margin: 0 auto;">
            <div class="card-header text-center">
                <div style="font-size: 5rem; margin-bottom: 1rem;">👤</div>
                <h2 class="card-title">${customer.get('name').getAsString()}</h2>
                <p style="color: var(--text-secondary);">${customer.get('email').getAsString()}</p>
            </div>
            
            <div class="order-details mt-4">
                <div class="detail-card">
                    <div class="detail-label">Customer ID</div>
                    <div class="detail-value">#${customer.get('customer_id').getAsInt()}</div>
                </div>
                <div class="detail-card">
                    <div class="detail-label">Member Status</div>
                    <div class="detail-value">
                        <c:choose>
                            <c:when test="${customer.get('loyalty_points').getAsInt() > 100}">
                                <span class="badge badge-success">Gold Member</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-info">Regular Member</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="detail-card" style="grid-column: span 2;">
                    <div class="detail-label">Loyalty Rewards</div>
                    <div class="detail-value" style="font-size: 2rem; color: #f2c94c;">
                        ✨ ${customer.get('loyalty_points').getAsInt()} Points
                    </div>
                    <p style="font-size: 0.8rem; color: var(--text-muted); margin-top: 0.5rem;">
                        You earn 1 point for every $10 spent.
                    </p>
                </div>
            </div>

            <div class="mt-4 text-center">
                <a href="${pageContext.request.contextPath}/ordersHistory?customer_id=${customer.get('customer_id').getAsInt()}" class="btn btn-primary">
                    View My Orders
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
