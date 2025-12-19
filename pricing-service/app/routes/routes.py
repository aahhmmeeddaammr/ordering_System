from flask import request, jsonify
from ..services.services import calculate_order_pricing

def register_routes(app):
    @app.route("/api/pricing/calculate", methods=["POST"])
    def calculate_pricing_route():
        try:
            data = request.get_json()
            
            if not data:
                return jsonify({
                    "success": False,
                    "error": "Request body must be JSON"
                }), 400
            
            if "products" not in data or not isinstance(data["products"], list):
                return jsonify({
                    "success": False,
                    "error": "Missing or invalid required field: products (must be a list)"
                }), 400
            
            if len(data["products"]) == 0:
                return jsonify({
                    "success": False,
                    "error": "Products list cannot be empty"
                }), 400
            
            products = data.get("products")
            region = data.get("region", "Egypt")
            
            result = calculate_order_pricing(products, region)
            
            if result["success"]:
                return jsonify(result), 200
            else:
                return jsonify(result), 400
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
    
    @app.route("/health", methods=["GET"])
    def health_check():
        return jsonify({"status": "Pricing Service is running", "port": 5003}), 200
