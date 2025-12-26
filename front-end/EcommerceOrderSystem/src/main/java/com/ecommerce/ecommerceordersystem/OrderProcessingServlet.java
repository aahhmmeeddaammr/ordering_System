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
import java.util.ArrayList;
import java.util.List;

/**
 * Scenario-1: Part 1
 * Checks availability and calculates total pricing before checkout
 */
@WebServlet(name = "orderProcessingServlet", urlPatterns = {"/processOrder"})
public class OrderProcessingServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String[] productIds = request.getParameterValues("selected_products");
            
            if (productIds == null || productIds.length == 0) {
                request.setAttribute("error", "Please select at least one product.");
                request.getRequestDispatcher("/products").forward(request, response);
                return;
            }
            
            JsonArray productsToPrice = new JsonArray();
            List<String> errors = new ArrayList<>();
            
            for (String pidStr : productIds) {
                int pid = Integer.parseInt(pidStr);
                String qtyStr = request.getParameter("quantity_" + pid);
                int qty = (qtyStr != null && !qtyStr.isEmpty()) ? Integer.parseInt(qtyStr) : 1;
                
                // 1. Check selected quantity against available quantity
                String inventoryResponseStr = HttpUtil.sendGet(
                        HttpUtil.INVENTORY_SERVICE + "/api/inventory/check/" + pid
                );
                JsonObject invResponse = gson.fromJson(inventoryResponseStr, JsonObject.class);
                
                if (invResponse.get("success").getAsBoolean()) {
                    int available = invResponse.get("quantity_available").getAsInt();
                    if (qty > available) {
                        errors.add("Product " + invResponse.get("product_name").getAsString() + 
                                  " only has " + available + " units available.");
                    } else {
                        JsonObject p = new JsonObject();
                        p.addProperty("product_id", pid);
                        p.addProperty("quantity", qty);
                        p.addProperty("product_name", invResponse.get("product_name").getAsString());
                        p.addProperty("unit_price", invResponse.get("unit_price").getAsDouble());
                        productsToPrice.add(p);
                    }
                } else {
                    errors.add("Product ID " + pid + " not found in inventory.");
                }
            }
            
            if (!errors.isEmpty()) {
                request.setAttribute("error", String.join("<br>", errors));
                request.getRequestDispatcher("/products").forward(request, response);
                return;
            }
            
            // 2. Calculate total amount
            JsonObject pricingRequest = new JsonObject();
            pricingRequest.add("products", productsToPrice);
            pricingRequest.addProperty("region", "Egypt"); // Default region
            
            String pricingResponseStr = HttpUtil.sendPost(
                    HttpUtil.PRICING_SERVICE + "/api/pricing/calculate",
                    gson.toJson(pricingRequest)
            );
            JsonObject pricingResponse = gson.fromJson(pricingResponseStr, JsonObject.class);
            
            if (pricingResponse.get("success").getAsBoolean()) {
                // Pass results to checkout.jsp
                request.setAttribute("pricingDetails", pricingResponse);
                request.setAttribute("selectedProducts", productsToPrice);
                request.setAttribute("totalAmount", pricingResponse.get("final_total").getAsDouble());
                
                // Fetch customers for the selection form in checkout.jsp
                fetchCustomers(request);
                
                request.getRequestDispatcher("/checkout.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Pricing calculation skipped: " + pricingResponse.get("error").getAsString());
                request.getRequestDispatcher("/products").forward(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Error processing order: " + e.getMessage());
            request.getRequestDispatcher("/products").forward(request, response);
        }
    }
    
    private void fetchCustomers(HttpServletRequest request) {
        JsonArray customers = new JsonArray();
        for (int i = 1; i <= 3; i++) {
            try {
                String response = HttpUtil.sendGet(HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + i);
                JsonObject customer = gson.fromJson(response, JsonObject.class);
                if (customer.get("success").getAsBoolean()) {
                    customers.add(customer);
                }
            } catch (Exception e) {}
        }
        request.setAttribute("customers", customers);
    }
}
