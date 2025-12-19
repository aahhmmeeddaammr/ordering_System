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
 * Servlet to handle checkout page - loads products and customers
 */
@WebServlet(name = "checkoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Fetch all products from Inventory Service
            String inventoryResponse = HttpUtil.sendGet(
                    HttpUtil.INVENTORY_SERVICE + "/api/inventory/products"
            );
            
            JsonObject jsonResponse = gson.fromJson(inventoryResponse, JsonObject.class);
            
            if (jsonResponse.has("success") && jsonResponse.get("success").getAsBoolean()) {
                JsonArray products = jsonResponse.getAsJsonArray("products");
                request.setAttribute("products", products);
                request.setAttribute("productsJson", products.toString());
            } else {
                request.setAttribute("products", new JsonArray());
                request.setAttribute("productsJson", "[]");
            }
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("products", new JsonArray());
            request.setAttribute("productsJson", "[]");
        } catch (Exception e) {
            request.setAttribute("error", "Unable to connect to Inventory Service: " + e.getMessage());
            request.setAttribute("products", new JsonArray());
            request.setAttribute("productsJson", "[]");
        }
        
        // Fetch customers
        try {
            JsonArray customers = new JsonArray();
            
            for (int i = 1; i <= 3; i++) {
                try {
                    String customerResponse = HttpUtil.sendGet(
                            HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + i
                    );
                    JsonObject customer = gson.fromJson(customerResponse, JsonObject.class);
                    if (customer.has("success") && customer.get("success").getAsBoolean()) {
                        JsonObject customerData = new JsonObject();
                        customerData.addProperty("customer_id", customer.get("customer_id").getAsInt());
                        customerData.addProperty("name", customer.get("name").getAsString());
                        customerData.addProperty("email", customer.get("email").getAsString());
                        customerData.addProperty("loyalty_points", customer.get("loyalty_points").getAsInt());
                        customers.add(customerData);
                    }
                } catch (Exception e) {
                    // Skip this customer
                }
            }
            
            request.setAttribute("customers", customers);
            request.setAttribute("customersJson", customers.toString());
            
        } catch (Exception e) {
            request.setAttribute("customers", new JsonArray());
            request.setAttribute("customersJson", "[]");
        }
        
        // Forward to checkout.jsp
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }
}
