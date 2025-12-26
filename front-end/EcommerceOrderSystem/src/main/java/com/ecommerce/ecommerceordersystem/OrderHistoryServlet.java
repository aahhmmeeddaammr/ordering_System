package com.ecommerce.ecommerceordersystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.io.IOException;

 
@WebServlet(name = "orderHistoryServlet", urlPatterns = {"/orders"})
public class OrderHistoryServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        
        String customerIdParam = request.getParameter("customer_id");
        int customerId = 1; 
        
        if (customerIdParam != null && !customerIdParam.isEmpty()) {
            try {
                customerId = Integer.parseInt(customerIdParam);
            } catch (NumberFormatException e) {
                customerId = 1;
            }
        }
        
        request.setAttribute("customerId", customerId);
        
        try {
            
            String customerResponse = HttpUtil.sendGet(
                    HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId
            );
            JsonObject customerJson = gson.fromJson(customerResponse, JsonObject.class);
            
            if (customerJson.has("success") && customerJson.get("success").getAsBoolean()) {
                request.setAttribute("customerName", 
                        customerJson.has("name") ? customerJson.get("name").getAsString() : "Unknown");
            } else {
                request.setAttribute("customerName", "Unknown");
            }
            
            
            String ordersResponse = HttpUtil.sendGet(
                    HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId + "/orders"
            );
            
            JsonObject ordersJson = gson.fromJson(ordersResponse, JsonObject.class);
            
            if (ordersJson.has("success") && ordersJson.get("success").getAsBoolean()) {
                JsonArray orders = ordersJson.getAsJsonArray("orders");
                
                
                JsonArray enrichedOrders = new JsonArray();
                
                for (int i = 0; i < orders.size(); i++) {
                    JsonObject order = orders.get(i).getAsJsonObject();
                    int orderId = order.get("order_id").getAsInt();
                    
                    try {
                        
                        String orderDetailResponse = HttpUtil.sendGet(
                                HttpUtil.ORDER_SERVICE + "/api/orders/" + orderId
                        );
                        
                        JsonObject orderDetail = gson.fromJson(orderDetailResponse, JsonObject.class);
                        
                        if (orderDetail.has("success") && orderDetail.get("success").getAsBoolean()) {
                            
                            JsonObject enrichedOrder = new JsonObject();
                            enrichedOrder.addProperty("order_id", orderId);
                            enrichedOrder.addProperty("order_date", 
                                    order.has("order_date") ? order.get("order_date").getAsString() : "");
                            enrichedOrder.addProperty("status", 
                                    order.has("status") ? order.get("status").getAsString() : "unknown");
                            enrichedOrder.addProperty("total_amount", 
                                    orderDetail.has("total_amount") ? orderDetail.get("total_amount").getAsDouble() : 0);
                            
                            
                            if (orderDetail.has("items")) {
                                enrichedOrder.add("products", orderDetail.getAsJsonArray("items"));
                            } else if (orderDetail.has("products")) {
                                enrichedOrder.add("products", orderDetail.getAsJsonArray("products"));
                            } else {
                                enrichedOrder.add("products", new JsonArray());
                            }
                            
                            enrichedOrders.add(enrichedOrder);
                        } else {
                            
                            enrichedOrders.add(order);
                        }
                    } catch (Exception e) {
                        
                        enrichedOrders.add(order);
                    }
                }
                
                request.setAttribute("orders", enrichedOrders);
                request.setAttribute("ordersJson", enrichedOrders.toString());
                request.setAttribute("orderCount", enrichedOrders.size());
            } else {
                request.setAttribute("orders", new JsonArray());
                request.setAttribute("ordersJson", "[]");
                request.setAttribute("orderCount", 0);
                
                if (ordersJson.has("error")) {
                    request.setAttribute("error", ordersJson.get("error").getAsString());
                }
            }
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("error", "Service communication interrupted");
            setDefaultAttributes(request);
        } catch (Exception e) {
            request.setAttribute("error", "Unable to connect to services: " + e.getMessage());
            setDefaultAttributes(request);
        }
        
        
        request.getRequestDispatcher("/view_orders_history.jsp").forward(request, response);
    }
    
    private void setDefaultAttributes(HttpServletRequest request) {
        request.setAttribute("customerName", "Unknown");
        request.setAttribute("orders", new JsonArray());
        request.setAttribute("ordersJson", "[]");
        request.setAttribute("orderCount", 0);
    }
}
