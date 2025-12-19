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
import java.io.PrintWriter;

/**
 * Servlet to fetch customers from Customer Service
 * Provides both page forwarding and JSON API endpoints
 */
@WebServlet(name = "customerServlet", urlPatterns = {"/customers", "/api/customers"})
public class CustomerServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getServletPath();
        
        // API endpoint - return JSON
        if (pathInfo.startsWith("/api")) {
            handleApiRequest(request, response);
        } else {
            // Page request - forward to JSP
            handlePageRequest(request, response);
        }
    }
    
    private void handleApiRequest(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String customerId = request.getParameter("id");
        
        try {
            if (customerId != null) {
                // Get specific customer
                String customerResponse = HttpUtil.sendGet(
                        HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId
                );
                out.print(customerResponse);
            } else {
                // Return list of sample customers (fetched individually)
                // In a real app, you'd have a /api/customers endpoint
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
                        // Skip this customer if there's an error
                    }
                }
                
                JsonObject result = new JsonObject();
                result.addProperty("success", true);
                result.add("customers", customers);
                out.print(gson.toJson(result));
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("error", "Service communication interrupted");
            out.print(gson.toJson(error));
        } catch (Exception e) {
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("error", "Unable to connect to Customer Service: " + e.getMessage());
            out.print(gson.toJson(error));
        }
    }
    
    private void handlePageRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Fetch customers for the page
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
                    // Skip this customer if there's an error
                }
            }
            
            request.setAttribute("customers", customers);
            request.setAttribute("customersJson", customers.toString());
            
        } catch (Exception e) {
            request.setAttribute("error", "Unable to load customers: " + e.getMessage());
            request.setAttribute("customers", new JsonArray());
            request.setAttribute("customersJson", "[]");
        }
        
        request.getRequestDispatcher("/customers.jsp").forward(request, response);
    }
}
