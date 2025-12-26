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

 
@WebServlet(name = "orderServlet", urlPatterns = {"/submitOrder"})
public class OrderServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.sendRedirect(request.getContextPath() + "/checkout");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            
            String customerId = request.getParameter("customer_id");
            String[] productIds = request.getParameterValues("product_id");
            String[] quantities = request.getParameterValues("quantity");
            String totalAmount = request.getParameter("total_amount");
            String region = request.getParameter("region");
            
            
            if (customerId == null || customerId.isEmpty()) {
                request.setAttribute("error", "Please select a customer");
                request.getRequestDispatcher("/checkout").forward(request, response);
                return;
            }
            
            if (productIds == null || productIds.length == 0) {
                request.setAttribute("error", "Please select at least one product");
                request.getRequestDispatcher("/checkout").forward(request, response);
                return;
            }
            
            
            JsonArray products = new JsonArray();
            for (int i = 0; i < productIds.length; i++) {
                if (productIds[i] != null && !productIds[i].isEmpty()) {
                    int qty = 1;
                    if (quantities != null && i < quantities.length && quantities[i] != null) {
                        try {
                            qty = Integer.parseInt(quantities[i]);
                        } catch (NumberFormatException e) {
                            qty = 1;
                        }
                    }
                    
                    if (qty > 0) {
                        JsonObject product = new JsonObject();
                        product.addProperty("product_id", Integer.parseInt(productIds[i]));
                        product.addProperty("quantity", qty);
                        products.add(product);
                    }
                }
            }
            
            if (products.isEmpty()) {
                request.setAttribute("error", "Please add products to your cart");
                request.getRequestDispatcher("/checkout").forward(request, response);
                return;
            }
            
            
            JsonObject pricingRequest = new JsonObject();
            pricingRequest.add("products", products);
            pricingRequest.addProperty("region", region != null ? region : "Egypt");
            
            String pricingResponseStr = HttpUtil.sendPost(
                    HttpUtil.PRICING_SERVICE + "/api/pricing/calculate",
                    gson.toJson(pricingRequest)
            );
            
            JsonObject pricingResponse = gson.fromJson(pricingResponseStr, JsonObject.class);
            
            double finalTotal = 0;
            if (pricingResponse.has("success") && pricingResponse.get("success").getAsBoolean()) {
                finalTotal = pricingResponse.get("final_total").getAsDouble();
            } else if (totalAmount != null && !totalAmount.isEmpty()) {
                finalTotal = Double.parseDouble(totalAmount);
            }
            
            
            JsonObject orderRequest = new JsonObject();
            orderRequest.addProperty("customer_id", Integer.parseInt(customerId));
            orderRequest.add("products", products);
            orderRequest.addProperty("total_amount", finalTotal);
            
            
            String orderResponseStr = HttpUtil.sendPost(
                    HttpUtil.ORDER_SERVICE + "/api/orders/create",
                    gson.toJson(orderRequest)
            );
            
            JsonObject orderResponse = gson.fromJson(orderResponseStr, JsonObject.class);
            
            if (orderResponse.has("success") && orderResponse.get("success").getAsBoolean()) {
                int orderId = orderResponse.get("order_id").getAsInt();
                
                
                for (int i = 0; i < products.size(); i++) {
                    JsonObject product = products.get(i).getAsJsonObject();
                    int productId = product.get("product_id").getAsInt();
                    int qty = product.get("quantity").getAsInt();
                    
                    try {
                        JsonObject inventoryUpdate = new JsonObject();
                        inventoryUpdate.addProperty("product_id", productId);
                        inventoryUpdate.addProperty("quantity", qty);
                        
                        HttpUtil.sendPut(
                                HttpUtil.INVENTORY_SERVICE + "/api/inventory/update",
                                gson.toJson(inventoryUpdate)
                        );
                    } catch (Exception e) {
                        
                    }
                }
                JsonObject notificationRequest = new JsonObject();
                notificationRequest.addProperty("order_id", orderId);
                notificationRequest.addProperty("notification_type", "order_confirmation");
                
                String notificationResponseStr = "";
                boolean notificationSent = false;
                try {
                    notificationResponseStr = HttpUtil.sendPost(
                            HttpUtil.NOTIFICATION_SERVICE + "/api/notifications/send",
                            gson.toJson(notificationRequest)
                    );
                    JsonObject notificationResponse = gson.fromJson(notificationResponseStr, JsonObject.class);
                    notificationSent = notificationResponse.has("success") && 
                            notificationResponse.get("success").getAsBoolean();
                } catch (Exception e) {
                    
                    notificationSent = false;
                }
                
                
                int pointsToAdd = (int) Math.floor(finalTotal / 10);
                if (pointsToAdd > 0) {
                    try {
                        JsonObject loyaltyRequest = new JsonObject();
                        loyaltyRequest.addProperty("points", pointsToAdd);
                        
                        HttpUtil.sendPut(
                                HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId + "/loyalty",
                                gson.toJson(loyaltyRequest)
                        );
                    } catch (Exception e) {
                        
                        
                    }
                }
                
                
                String customerResponseStr = HttpUtil.sendGet(
                        HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId
                );
                JsonObject customerResponse = gson.fromJson(customerResponseStr, JsonObject.class);
                
                
                request.setAttribute("orderId", orderId);
                request.setAttribute("orderResponse", orderResponse.toString());
                request.setAttribute("pricingResponse", pricingResponse.toString());
                request.setAttribute("customerResponse", customerResponse.toString());
                request.setAttribute("notificationSent", notificationSent);
                request.setAttribute("customerName", 
                        customerResponse.has("name") ? customerResponse.get("name").getAsString() : "Unknown");
                request.setAttribute("customerEmail", 
                        customerResponse.has("email") ? customerResponse.get("email").getAsString() : "");
                request.setAttribute("finalTotal", finalTotal);
                request.setAttribute("timestamp", orderResponse.has("timestamp") ? 
                        orderResponse.get("timestamp").getAsString() : "");
                
                
                request.getRequestDispatcher("/confirmation.jsp").forward(request, response);
                
            } else {
                String errorMsg = orderResponse.has("error") ? 
                        orderResponse.get("error").getAsString() : "Failed to create order";
                request.setAttribute("error", errorMsg);
                request.getRequestDispatcher("/checkout").forward(request, response);
            }
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("error", "Service communication interrupted");
            request.getRequestDispatcher("/checkout").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error processing order: " + e.getMessage());
            request.getRequestDispatcher("/checkout").forward(request, response);
        }
    }
}
