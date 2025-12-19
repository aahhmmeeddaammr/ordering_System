<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.ecommerce.ecommerceordersystem.HttpUtil" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.JsonObject" %>
<%
    // Proxy to fetch order details from the backend Order Service
    // This avoids CORS issues by making the request server-side
    
    String orderId = request.getParameter("order_id");
    
    if (orderId == null || orderId.isEmpty()) {
        response.setStatus(400);
        out.print("{\"success\": false, \"error\": \"Missing order_id parameter\"}");
        return;
    }
    
    try {
        // Call the Order Service
        String orderResponse = HttpUtil.sendGet(
                HttpUtil.ORDER_SERVICE + "/api/orders/" + orderId
        );
        
        // Return the response directly
        out.print(orderResponse);
        
    } catch (Exception e) {
        response.setStatus(500);
        out.print("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
    }
%>
