package com.ecommerce.ecommerceordersystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.IOException;

/**
 * Scenario-2: Profile
 * Fetches customer details from Customer Service
 */
@WebServlet(name = "profileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String customerId = request.getParameter("customer_id");
        if (customerId == null || customerId.isEmpty()) {
            customerId = "1"; // Default for demo
        }
        
        try {
            // Get all customer details including loyalty points
            String customerResponseStr = HttpUtil.sendGet(
                    HttpUtil.CUSTOMER_SERVICE + "/api/customers/" + customerId
            );
            JsonObject customerResponse = gson.fromJson(customerResponseStr, JsonObject.class);
            
            if (customerResponse.get("success").getAsBoolean()) {
                request.setAttribute("customer", customerResponse);
                request.getRequestDispatcher("/profile.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Customer profile not found.");
                request.getRequestDispatcher("/index.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Error loading profile: " + e.getMessage());
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }
}
