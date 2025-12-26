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

 
@WebServlet(name = "productServlet", urlPatterns = {"/products", ""})
public class ProductServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            
            String inventoryResponse = HttpUtil.sendGet(
                    HttpUtil.INVENTORY_SERVICE + "/api/inventory/products"
            );
            
            JsonObject jsonResponse = gson.fromJson(inventoryResponse, JsonObject.class);
            
            if (jsonResponse.has("success") && jsonResponse.get("success").getAsBoolean()) {
                JsonArray products = jsonResponse.getAsJsonArray("products");
                request.setAttribute("products", products);
                request.setAttribute("productsJson", products.toString());
            } else {
                request.setAttribute("error", "Failed to load products from inventory service");
                request.setAttribute("products", new JsonArray());
                request.setAttribute("productsJson", "[]");
            }
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("error", "Service communication interrupted");
            request.setAttribute("products", new JsonArray());
            request.setAttribute("productsJson", "[]");
        } catch (Exception e) {
            request.setAttribute("error", "Unable to connect to Inventory Service: " + e.getMessage());
            request.setAttribute("products", new JsonArray());
            request.setAttribute("productsJson", "[]");
        }
        
        
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
