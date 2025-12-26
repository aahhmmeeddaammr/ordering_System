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

 
@WebServlet(name = "pricingServlet", urlPatterns = {"/api/pricing"})
public class PricingServlet extends HttpServlet {
    
    private final Gson gson = new Gson();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                sb.append(line);
            }
            String requestBody = sb.toString();
            
            
            JsonObject requestJson = gson.fromJson(requestBody, JsonObject.class);
            
            
            JsonObject pricingRequest = new JsonObject();
            pricingRequest.add("products", requestJson.getAsJsonArray("products"));
            pricingRequest.addProperty("region", 
                    requestJson.has("region") ? requestJson.get("region").getAsString() : "Egypt");
            
            
            String pricingResponse = HttpUtil.sendPost(
                    HttpUtil.PRICING_SERVICE + "/api/pricing/calculate",
                    gson.toJson(pricingRequest)
            );
            
            out.print(pricingResponse);
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("error", "Service communication interrupted");
            out.print(gson.toJson(error));
        } catch (Exception e) {
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("error", "Unable to calculate pricing: " + e.getMessage());
            out.print(gson.toJson(error));
        }
    }
}
