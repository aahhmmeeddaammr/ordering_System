from ..utils.db_connection import get_db_connection
import requests
import os
from datetime import datetime

def send_order_notification(order_id, notification_type="order_confirmation"):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            order_service_url = os.getenv("ORDER_URL", "http://localhost:5001")
            order_response = requests.get(
                f"{order_service_url}/api/orders/{order_id}",
                timeout=5
            )
            
            if not order_response.ok:
                return {"success": False, "error": f"Order {order_id} not found"}
            
            order_data = order_response.json()
            customer_id = order_data.get("customer_id")
            total_amount = order_data.get("total_amount")
            items = order_data.get("items", [])
            
        except Exception as e:
            return {"success": False, "error": f"Failed to retrieve order: {str(e)}"}
        
        customer_email = None
        customer_phone = None
        customer_name = None
        
        try:
            customer_service_url = os.getenv("CUSTOMER_URL", "http://localhost:5004")
            customer_response = requests.get(
                f"{customer_service_url}/api/customers/{customer_id}",
                timeout=5
            )
            
            if customer_response.ok:
                customer_data = customer_response.json()
                customer_email = customer_data.get("email")
                customer_phone = customer_data.get("phone")
                customer_name = customer_data.get("name")
        
        except Exception as e:
            print(f"Warning: Could not retrieve customer info: {str(e)}")
        
        item_details = []
        try:
            inventory_service_url = os.getenv("INVENTORY_URL", "http://localhost:5002")
            for item in items:
                product_id = item.get("product_id")
                try:
                    inv_response = requests.get(
                        f"{inventory_service_url}/api/inventory/check/{product_id}",
                        timeout=5
                    )
                    if inv_response.ok:
                        inv_data = inv_response.json()
                        item_details.append({
                            "product_id": product_id,
                            "product_name": inv_data.get("product_name"),
                            "quantity": item.get("quantity"),
                            "status": inv_data.get("status")
                        })
                except:
                    item_details.append({
                        "product_id": product_id,
                        "quantity": item.get("quantity"),
                        "status": "unknown"
                    })
        
        except Exception as e:
            print(f"Warning: Could not retrieve inventory info: {str(e)}")
        
        notification_message = f"""
Order Confirmation - Order #{order_id}
Customer: {customer_name or 'N/A'}
Order Total: ${total_amount:.2f}

Items:
"""
        for item in item_details:
            notification_message += f"\n- {item.get('product_name', 'Product')} (ID: {item.get('product_id')}): {item.get('quantity')} units - {item.get('status')}"
        
        notification_message += f"\n\nThank you for your order!"
        
        cursor.execute(
            "INSERT INTO notification_log (order_id, customer_id, notification_type, message) VALUES (%s, %s, %s, %s)",
            (order_id, customer_id, notification_type, notification_message)
        )
        conn.commit()
        
        notification_id = cursor.lastrowid
        
        print("=" * 60)
        print(f"[NOTIFICATION SERVICE] Sending {notification_type.upper()}")
        print("=" * 60)
        if customer_email:
            print(f"EMAIL SENT TO: {customer_email}")
        if customer_phone:
            print(f"SMS SENT TO: {customer_phone}")
        print(f"Subject: Order #{order_id} Confirmed")
        print(f"Body:\n{notification_message}")
        print("=" * 60)
        
        return {
            "success": True,
            "notification_id": notification_id,
            "order_id": order_id,
            "customer_id": customer_id,
            "customer_email": customer_email,
            "customer_phone": customer_phone,
            "notification_type": notification_type,
            "timestamp": datetime.now().isoformat(),
            "message": f"Notification sent successfully via email to {customer_email}"
        }
    
    except Exception as e:
        if conn:
            conn.rollback()
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()
