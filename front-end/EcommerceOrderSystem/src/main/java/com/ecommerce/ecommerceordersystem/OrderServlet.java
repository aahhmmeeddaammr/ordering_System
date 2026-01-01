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
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String customerId = request.getParameter("customer_id");
            String[] productIds = request.getParameterValues("product_id");
            String[] quantities = request.getParameterValues("quantity");
            String region = request.getParameter("region");

            // Validation
            if (customerId == null || customerId.isEmpty() || productIds == null || productIds.length == 0) {
                forwardError(request, response, "Please select a customer and at least one product");
                return;
            }

            // Build products array
            JsonArray products = new JsonArray();
            for (int i = 0; i < productIds.length; i++) {
                if (productIds[i] == null || productIds[i].isEmpty()) continue;
                int qty = (quantities != null && i < quantities.length) ? parseIntOrDefault(quantities[i], 1) : 1;
                if (qty > 0) {
                    JsonObject p = new JsonObject();
                    p.addProperty("product_id", Integer.parseInt(productIds[i]));
                    p.addProperty("quantity", qty);
                    products.add(p);
                }
            }

            if (products.isEmpty()) {
                forwardError(request, response, "Please add products to your cart");
                return;
            }

            // Use the total calculated on checkout page (already called pricing API there)
            double finalTotal = parseDoubleOrDefault(request.getParameter("total_amount"), 0);
            if (finalTotal <= 0) {
                forwardError(request, response, "Invalid order total");
                return;
            }

            // Create order
            JsonObject orderReq = new JsonObject();
            orderReq.addProperty("customer_id", Integer.parseInt(customerId));
            orderReq.add("products", products);
            orderReq.addProperty("total_amount", finalTotal);
            JsonObject orderRes = gson.fromJson(
                HttpUtil.sendPost(HttpUtil.ORDER_SERVICE + "/api/orders/create", gson.toJson(orderReq)), 
                JsonObject.class
            );

            if (!orderRes.has("success") || !orderRes.get("success").getAsBoolean()) {
                forwardError(request, response, orderRes.has("error") ? orderRes.get("error").getAsString() : "Failed to create order");
                return;
            }

            int orderId = orderRes.get("order_id").getAsInt();

            // Update inventory (fire-and-forget)
            for (var el : products) {
                JsonObject p = el.getAsJsonObject();
                try {
                    JsonObject inv = new JsonObject();
                    inv.addProperty("product_id", p.get("product_id").getAsInt());
                    inv.addProperty("quantity", p.get("quantity").getAsInt());
                    HttpUtil.sendPut(HttpUtil.INVENTORY_SERVICE + "/api/inventory/update", gson.toJson(inv));
                } catch (Exception ignored) {}
            }

            boolean notificationSent = false;
            try {
                JsonObject notifReq = new JsonObject();
                notifReq.addProperty("order_id", orderId);
                notifReq.addProperty("notification_type", "order_confirmation");
                String notifResponse = HttpUtil.sendPost(HttpUtil.NOTIFICATION_SERVICE + "/api/notifications/send", gson.toJson(notifReq));
                
                JsonObject notifRes = gson.fromJson(notifResponse, JsonObject.class);
                notificationSent = notifRes != null && notifRes.has("success") && notifRes.get("success").getAsBoolean();
                
                if (!notificationSent && notifRes != null && notifRes.has("error")) {
                    System.err.println("[OrderServlet] Notification error: " + notifRes.get("error").getAsString());
                }
            } catch (Exception e) {
                System.err.println("[OrderServlet] Notification exception: " + e.getMessage());
            }

            int points = (int) (finalTotal / 10);
            if (points > 0) {
                try {
                    JsonObject loyaltyReq = new JsonObject();
                    loyaltyReq.addProperty("points", points);
                    HttpUtil.sendPut(HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId + "/loyalty", gson.toJson(loyaltyReq));
                } catch (Exception ignored) {}
            }

            String customerName = request.getParameter("customer_name");
            String customerEmail = request.getParameter("customer_email");
            String orderItemsJson = request.getParameter("order_items_json");
            if (customerName == null || customerName.isEmpty()) customerName = "Unknown";
            if (customerEmail == null) customerEmail = "";
            if (orderItemsJson == null || orderItemsJson.isEmpty()) orderItemsJson = "{}";

            request.setAttribute("orderId", orderId);
            request.setAttribute("customerName", customerName);
            request.setAttribute("customerEmail", customerEmail);
            request.setAttribute("finalTotal", finalTotal);
            request.setAttribute("notificationSent", notificationSent);
            request.setAttribute("pricingResponse", orderItemsJson);
            request.getRequestDispatcher("/confirmation.jsp").forward(request, response);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            forwardError(request, response, "Service communication interrupted");
        } catch (Exception e) {
            forwardError(request, response, "Error processing order: " + e.getMessage());
        }
    }

    private void forwardError(HttpServletRequest request, HttpServletResponse response, String error) 
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.getRequestDispatcher("/checkout").forward(request, response);
    }

    private int parseIntOrDefault(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private double parseDoubleOrDefault(String s, double def) {
        try { return Double.parseDouble(s); } catch (Exception e) { return def; }
    }
}
