from flask import request, jsonify
from ..services.services import create_order, get_order_details

def register_routes(app):
    @app.route("/api/orders/create", methods=["POST"])
    def create_order_route():
        try:
            data = request.get_json()
            
            if not data:
                return jsonify({
                    "success": False,
                    "error": "Request body must be JSON"
                }), 400
            
            if "customer_id" not in data:
                return jsonify({
                    "success": False,
                    "error": "Missing required field: customer_id"
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
            
            for product in data["products"]:
                if "product_id" not in product or "quantity" not in product:
                    return jsonify({
                        "success": False,
                        "error": "Each product must have product_id and quantity"
                    }), 400
            
            customer_id = data.get("customer_id")
            products = data.get("products")
            total_amount = data.get("total_amount", 0)
            
            result = create_order(customer_id, products, total_amount)
            
            if result["success"]:
                return jsonify(result), 201
            else:
                return jsonify(result), 400
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
    
    @app.route("/api/orders/<int:order_id>", methods=["GET"])
    def get_order_route(order_id):
        try:
            result = get_order_details(order_id)
            
            if result["success"]:
                return jsonify(result), 200
            else:
                return jsonify(result), 404
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
    
    @app.route("/api/orders", methods=["GET"])
    def get_orders_by_customer_route():
        try:
            customer_id = request.args.get("customer_id", type=int)
            
            if not customer_id:
                return jsonify({
                    "success": False,
                    "error": "Missing query parameter: customer_id"
                }), 400
            
            from ..services.services import get_customer_orders
            result = get_customer_orders(customer_id)
            
            if result["success"]:
                return jsonify(result), 200
            else:
                return jsonify(result), 404
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
    