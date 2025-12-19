from flask import request, jsonify
from ..services.services import get_customer_profile, update_loyalty_points, get_customer_order_history

def register_routes(app):
    @app.route("/api/customers/<int:customer_id>", methods=["GET"])
    def get_customer_profile_route(customer_id):
        try:
            result = get_customer_profile(customer_id)
            
            if result["success"]:
                return jsonify(result), 200
            else:
                return jsonify(result), 404
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
    
    @app.route("/api/customers/<int:customer_id>/orders", methods=["GET"])
    def get_customer_orders_route(customer_id):
        try:
            result = get_customer_order_history(customer_id)
            
            if result["success"]:
                return jsonify(result), 200
            else:
                return jsonify(result), 404
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
    
    @app.route("/api/customers/<int:customer_id>/loyalty", methods=["PUT"])
    def update_loyalty_points_route(customer_id):
        try:
            data = request.get_json()
            
            if not data or "points" not in data:
                return jsonify({
                    "success": False,
                    "error": "Missing required field: points"
                }), 400
            
            points = data.get("points")
            
            result = update_loyalty_points(customer_id, points)
            
            if result["success"]:
                return jsonify(result), 200
            else:
                return jsonify(result), 400
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
    
 