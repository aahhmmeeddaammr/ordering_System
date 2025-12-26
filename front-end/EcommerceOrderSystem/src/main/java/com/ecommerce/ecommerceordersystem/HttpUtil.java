package com.ecommerce.ecommerceordersystem;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

 
public class HttpUtil {
    
    private static final HttpClient client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();
    
    
    public static final String ORDER_SERVICE = "http://localhost:5001";
    public static final String INVENTORY_SERVICE = "http://localhost:5002";
    public static final String PRICING_SERVICE = "http://localhost:5003";
    public static final String CUSTOMER_SERVICE = "http://localhost:5004";
    public static final String NOTIFICATION_SERVICE = "http://localhost:5005";
    
     
    public static String sendGet(String url) throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Accept", "application/json")
                .GET()
                .build();
        
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }
    
     
    public static String sendPost(String url, String jsonBody) throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .header("Accept", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();
        
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }
    
     
    public static String sendPut(String url, String jsonBody) throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .header("Accept", "application/json")
                .PUT(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();
        
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }
    
     
    public static boolean isServiceAvailable(String serviceUrl) {
        try {
            String response = sendGet(serviceUrl + "/health");
            return response != null && response.contains("running");
        } catch (Exception e) {
            return false;
        }
    }
}
