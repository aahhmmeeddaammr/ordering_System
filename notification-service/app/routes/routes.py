from flask import request, jsonify
from ..services.services import send_order_notification

def register_routes(app):
    @app.route("/api/notifications/send", methods=["POST"])
    def send_notification_route():
        try:
            data = request.get_json()
            
            if not data:
                return jsonify({
                    "success": False,
                    "error": "Request body must be JSON"
                }), 400
            
            if "order_id" not in data:
                return jsonify({
                    "success": False,
                    "error": "Missing required field: order_id"
                }), 400
            
            order_id = data.get("order_id")
            notification_type = data.get("notification_type", "order_confirmation")
            
            result = send_order_notification(order_id, notification_type)
            
            if result["success"]:
                return jsonify(result), 201
            else:
                return jsonify(result), 400
        
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"Server error: {str(e)}"
            }), 500
    