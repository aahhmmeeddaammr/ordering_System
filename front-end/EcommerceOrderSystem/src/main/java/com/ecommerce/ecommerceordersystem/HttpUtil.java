package com.ecommerce.ecommerceordersystem;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

/**
 * Utility class for making HTTP requests to Flask microservices
 */
public class HttpUtil {
    
    private static final HttpClient client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();
    
    // Service URLs
    public static final String ORDER_SERVICE = "http://localhost:5001";
    public static final String INVENTORY_SERVICE = "http://localhost:5002";
    public static final String PRICING_SERVICE = "http://localhost:5003";
    public static final String CUSTOMER_SERVICE = "http://localhost:5004";
    public static final String NOTIFICATION_SERVICE = "http://localhost:5005";
    
    /**
     * Send a GET request to the specified URL
     * @param url The URL to send the request to
     * @return The response body as a string
     * @throws IOException If an I/O error occurs
     * @throws InterruptedException If the operation is interrupted
     */
    public static String sendGet(String url) throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Accept", "application/json")
                .GET()
                .build();
        
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }
    
    /**
     * Send a POST request with JSON body
     * @param url The URL to send the request to
     * @param jsonBody The JSON body to send
     * @return The response body as a string
     * @throws IOException If an I/O error occurs
     * @throws InterruptedException If the operation is interrupted
     */
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
    
    /**
     * Send a PUT request with JSON body
     * @param url The URL to send the request to
     * @param jsonBody The JSON body to send
     * @return The response body as a string
     * @throws IOException If an I/O error occurs
     * @throws InterruptedException If the operation is interrupted
     */
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
    
    /**
     * Check if a service is available by calling its health endpoint
     * @param serviceUrl The base URL of the service
     * @return true if the service is available, false otherwise
     */
    public static boolean isServiceAvailable(String serviceUrl) {
        try {
            String response = sendGet(serviceUrl + "/health");
            return response != null && response.contains("running");
        } catch (Exception e) {
            return false;
        }
    }
}
