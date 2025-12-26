package com.ecommerce.ecommerceordersystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Scenario-3: Order History
 * Fetches order history from Customer Service and details from Order Service
 */
@WebServlet(name = "orderHistoryServlet", urlPatterns = {"/ordersHistory"})
public class OrderHistoryServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String customerId = request.getParameter("customer_id");
        if (customerId == null || customerId.isEmpty()) {
            customerId = "1"; // Default for demo
        }
        
        try {
            // 1. Get orders history from Customer Service
            String historyResponseStr = HttpUtil.sendGet(
                    HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId + "/orders"
            );
            JsonObject historyResponse = gson.fromJson(historyResponseStr, JsonObject.class);
            
            if (historyResponse.get("success").getAsBoolean()) {
                JsonArray ordersBrief = historyResponse.getAsJsonArray("orders");
                JsonArray detailedOrders = new JsonArray();
                
                // 2. For each order, get full details from Order Service
                for (JsonElement element : ordersBrief) {
                    int orderId = element.getAsJsonObject().get("order_id").getAsInt();
                    
                    try {
                        String detailsResponseStr = HttpUtil.sendGet(
                                HttpUtil.ORDER_SERVICE + "/api/orders/" + orderId
                        );
                        JsonObject detailsResponse = gson.fromJson(detailsResponseStr, JsonObject.class);
                        if (detailsResponse.get("success").getAsBoolean()) {
                            detailedOrders.add(detailsResponse);
                        }
                    } catch (Exception e) {
                        // If detail fetch fails, at least show the brief info
                        detailedOrders.add(element);
                    }
                }
                
                request.setAttribute("orders", detailedOrders);
                request.getRequestDispatcher("/View_orders_history.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "No order history found for this customer.");
                request.getRequestDispatcher("/index.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Error loading order history: " + e.getMessage());
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }
}
