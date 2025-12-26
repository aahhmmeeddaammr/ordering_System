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

/**
 * Scenario-1: Part 2
 * Creates the order, updates loyalty points, and sends notification
 */
@WebServlet(name = "confirmOrderServlet", urlPatterns = {"/confirmOrder"})
public class ConfirmOrderServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 1. Read input data
            int customerId = Integer.parseInt(request.getParameter("customer_id"));
            double totalAmount = Double.parseDouble(request.getParameter("total_amount"));
            String productsJson = request.getParameter("products_json");
            JsonArray products = gson.fromJson(productsJson, JsonArray.class);
            
            // 2. Create Order
            JsonObject orderRequest = new JsonObject();
            orderRequest.addProperty("customer_id", customerId);
            orderRequest.add("products", products);
            orderRequest.addProperty("total_amount", totalAmount);
            
            String orderResponseStr = HttpUtil.sendPost(
                    HttpUtil.ORDER_SERVICE + "/api/orders/create",
                    gson.toJson(orderRequest)
            );
            JsonObject orderResponse = gson.fromJson(orderResponseStr, JsonObject.class);
            
            if (orderResponse.get("success").getAsBoolean()) {
                int orderId = orderResponse.get("order_id").getAsInt();
                
                // 3. Update Loyalty Points
                // Rule: 1 point for every $10 spent
                int pointsToAdd = (int) (totalAmount / 10);
                JsonObject loyaltyRequest = new JsonObject();
                loyaltyRequest.addProperty("points", pointsToAdd);
                
                HttpUtil.sendPut(
                        HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId + "/loyalty",
                        gson.toJson(loyaltyRequest)
                );
                
                // 4. Send Notification
                JsonObject notifyRequest = new JsonObject();
                notifyRequest.addProperty("order_id", orderId);
                notifyRequest.addProperty("notification_type", "order_confirmation");
                
                HttpUtil.sendPost(
                        HttpUtil.NOTIFICATION_SERVICE + "/api/notifications/send",
                        gson.toJson(notifyRequest)
                );
                
                // 5. Success - Show confirmation page
                request.setAttribute("order_details", orderResponse);
                request.setAttribute("order_id", orderId);
                request.setAttribute("total_amount", totalAmount);
                
                request.getRequestDispatcher("/confirmation.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Order Creation Failed: " + orderResponse.get("error").getAsString());
                request.getRequestDispatcher("/checkout.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Confirmation error: " + e.getMessage());
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
        }
    }
}
