package com.ecommerce.ecommerceordersystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.IOException;

 
@WebServlet(name = "profileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {
    
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
        
        try {
            
            String customerResponse = HttpUtil.sendGet(
                    HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId
            );
            
            JsonObject jsonResponse = gson.fromJson(customerResponse, JsonObject.class);
            
            if (jsonResponse.has("success") && jsonResponse.get("success").getAsBoolean()) {
                request.setAttribute("customerId", customerId);
                request.setAttribute("customerName", 
                        jsonResponse.has("name") ? jsonResponse.get("name").getAsString() : "Unknown");
                request.setAttribute("customerEmail", 
                        jsonResponse.has("email") ? jsonResponse.get("email").getAsString() : "");
                request.setAttribute("customerPhone", 
                        jsonResponse.has("phone") ? jsonResponse.get("phone").getAsString() : "");
                request.setAttribute("loyaltyPoints", 
                        jsonResponse.has("loyalty_points") ? jsonResponse.get("loyalty_points").getAsInt() : 0);
                request.setAttribute("createdAt", 
                        jsonResponse.has("created_at") ? jsonResponse.get("created_at").getAsString() : "");
            } else {
                request.setAttribute("error", "Customer not found");
                request.setAttribute("customerId", customerId);
                request.setAttribute("customerName", "Unknown");
                request.setAttribute("customerEmail", "");
                request.setAttribute("customerPhone", "");
                request.setAttribute("loyaltyPoints", 0);
                request.setAttribute("createdAt", "");
            }
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("error", "Service communication interrupted");
            setDefaultAttributes(request, customerId);
        } catch (Exception e) {
            request.setAttribute("error", "Unable to connect to Customer Service: " + e.getMessage());
            setDefaultAttributes(request, customerId);
        }
        
        
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }
    
    private void setDefaultAttributes(HttpServletRequest request, int customerId) {
        request.setAttribute("customerId", customerId);
        request.setAttribute("customerName", "Unknown");
        request.setAttribute("customerEmail", "");
        request.setAttribute("customerPhone", "");
        request.setAttribute("loyaltyPoints", 0);
        request.setAttribute("createdAt", "");
    }
}
