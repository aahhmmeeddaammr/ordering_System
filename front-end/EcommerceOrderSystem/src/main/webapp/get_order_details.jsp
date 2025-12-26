<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.ecommerce.ecommerceordersystem.HttpUtil" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.JsonObject" %>
<%
    
    
    
    String orderId = request.getParameter("order_id");
    
    if (orderId == null || orderId.isEmpty()) {
        response.setStatus(400);
        out.print("{\"success\": false, \"error\": \"Missing order_id parameter\"}");
        return;
    }
    
    try {
        
        String orderResponse = HttpUtil.sendGet(
                HttpUtil.ORDER_SERVICE + "/api/orders/" + orderId
        );
        
        
        out.print(orderResponse);
        
    } catch (Exception e) {
        response.setStatus(500);
        out.print("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
    }
%>
