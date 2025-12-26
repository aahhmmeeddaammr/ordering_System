<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.ecommerce.ecommerceordersystem.HttpUtil" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="com.google.gson.JsonObject" %>
<%
    
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(request.getContextPath() + "/checkout");
        return;
    }

    Gson gson = new Gson();
    
    try {
        
        String customerId = request.getParameter("customer_id");
        String[] productIds = request.getParameterValues("product_id");
        String[] quantities = request.getParameterValues("quantity");
        String totalAmount = request.getParameter("total_amount");
        String region = request.getParameter("region");
        
        
        if (customerId == null || customerId.isEmpty()) {
            request.setAttribute("error", "Please select a customer");
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
            return;
        }
        
        if (productIds == null || productIds.length == 0) {
            request.setAttribute("error", "Please select at least one product");
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
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
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
            return;
        }
        
        
        for (int i = 0; i < products.size(); i++) {
            JsonObject product = products.get(i).getAsJsonObject();
            int productId = product.get("product_id").getAsInt();
            int requestedQty = product.get("quantity").getAsInt();
            
            try {
                String stockResponse = HttpUtil.sendGet(
                        HttpUtil.INVENTORY_SERVICE + "/api/inventory/check/" + productId
                );
                JsonObject stockJson = gson.fromJson(stockResponse, JsonObject.class);
                
                if (stockJson.has("success") && stockJson.get("success").getAsBoolean()) {
                    int availableQty = stockJson.has("quantity_available") ? 
                            stockJson.get("quantity_available").getAsInt() : 0;
                    
                    if (requestedQty > availableQty) {
                        String productName = stockJson.has("product_name") ? 
                                stockJson.get("product_name").getAsString() : "Product #" + productId;
                        request.setAttribute("error", 
                                "Insufficient stock for " + productName + ". Available: " + availableQty + ", Requested: " + requestedQty);
                        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
                        return;
                    }
                }
            } catch (Exception e) {
                
            }
        }
        
        
        JsonObject pricingRequest = new JsonObject();
        pricingRequest.add("products", products);
        pricingRequest.addProperty("region", region != null ? region : "Egypt");
        
        double finalTotal = 0;
        JsonObject pricingResponse = new JsonObject();
        
        try {
            String pricingResponseStr = HttpUtil.sendPost(
                    HttpUtil.PRICING_SERVICE + "/api/pricing/calculate",
                    gson.toJson(pricingRequest)
            );
            pricingResponse = gson.fromJson(pricingResponseStr, JsonObject.class);
            
            if (pricingResponse.has("success") && pricingResponse.get("success").getAsBoolean()) {
                finalTotal = pricingResponse.get("final_total").getAsDouble();
            } else if (totalAmount != null && !totalAmount.isEmpty()) {
                finalTotal = Double.parseDouble(totalAmount);
            }
        } catch (Exception e) {
            if (totalAmount != null && !totalAmount.isEmpty()) {
                finalTotal = Double.parseDouble(totalAmount);
            }
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
            
            boolean notificationSent = false;
            try {
                String notificationResponseStr = HttpUtil.sendPost(
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
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);
        }
        
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        request.setAttribute("error", "Service communication interrupted");
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    } catch (Exception e) {
        request.setAttribute("error", "Error processing order: " + e.getMessage());
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }
%>
