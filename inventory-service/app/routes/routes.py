from flask import request, jsonify
from ..services.services import get_inventory_details, update_inventory, get_all_products

def register_routes(app):
    @app.route("/api/inventory/check/<int:product_id>", methods=["GET"])
    def check_inventory_route(product_id):
        result = get_inventory_details(product_id)
        return jsonify(result), 200 if result["success"] else 404
    
    @app.route("/api/inventory/update", methods=["PUT"])
    def update_inventory_route():
        try:
            data = request.get_json()
            
            if not data:
                return jsonify({
                    "success": False,
                    "error": "Request body must be JSON"
                }), 400
            
            if "product_id" not in data or "quantity" not in data:
                return jsonify({
                    "success": False,
                    "error": "Missing required fields: product_id, quantity"
                }), 400
            
            product_id = data.get("product_id")
            quantity = data.get("quantity")  
            
            result = update_inventory(product_id, quantity)
            
            if result["success"]:
                return jsonify(result), 200
            else:
                return jsonify(result), 400
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
    
    @app.route("/api/inventory/products", methods=["GET"])
    def get_all_products_route():
        try:
            result = get_all_products()
            
            if result["success"]:
                return jsonify(result), 200
            else:
                return jsonify(result), 404
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
  