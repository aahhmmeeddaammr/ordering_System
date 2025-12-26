from ..utils.db_connection import get_db_connection
import requests
import os

def get_customer_profile(customer_id):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute(
            "SELECT customer_id, name, email, phone, loyalty_points, created_at FROM customers WHERE customer_id = %s",
            (customer_id,)
        )
        customer = cursor.fetchone()
        
        if not customer:
            return {"success": False, "error": f"Customer {customer_id} not found"}
        
        return {
            "success": True,
            "customer_id": customer["customer_id"],
            "name": customer["name"],
            "email": customer["email"],
            "phone": customer["phone"],
            "loyalty_points": customer["loyalty_points"],
            "created_at": str(customer["created_at"])
        }
    
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()

def get_customer_order_history(customer_id):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        
        cursor.execute(
            "SELECT customer_id, name, email FROM customers WHERE customer_id = %s",
            (customer_id,)
        )
        customer = cursor.fetchone()
        
        if not customer:
            return {"success": False, "error": f"Customer {customer_id} not found"}
        
        
        try:
            order_service_url = os.getenv("ORDER_URL", "http://localhost:5001")
            response = requests.get(
                f"{order_service_url}/api/orders",
                params={"customer_id": customer_id},
                timeout=5
            )
            
            if response.ok:
                orders_data = response.json()
                return {
                    "success": True,
                    "customer_id": customer_id,
                    "customer_name": customer["name"],
                    "customer_email": customer["email"],
                    "orders": orders_data.get("orders", [])
                }
            else:
                return {
                    "success": True,
                    "customer_id": customer_id,
                    "customer_name": customer["name"],
                    "customer_email": customer["email"],
                    "orders": [],
                    "warning": "Could not retrieve orders from Order Service"
                }
        except Exception as e:
            return {
                "success": True,
                "customer_id": customer_id,
                "customer_name": customer["name"],
                "customer_email": customer["email"],
                "orders": [],
                "warning": f"Error retrieving orders: {str(e)}"
            }
    
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()

def update_loyalty_points(customer_id, points):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        
        cursor.execute(
            "SELECT customer_id, loyalty_points FROM customers WHERE customer_id = %s",
            (customer_id,)
        )
        customer = cursor.fetchone()
        
        if not customer:
            return {"success": False, "error": f"Customer {customer_id} not found"}
        
        
        new_points = customer["loyalty_points"] + points
        
        
        new_points = max(0, new_points)
        
        cursor.execute(
            "UPDATE customers SET loyalty_points = %s WHERE customer_id = %s",
            (new_points, customer_id)
        )
        conn.commit()
        
        return {
            "success": True,
            "customer_id": customer_id,
            "previous_points": customer["loyalty_points"],
            "points_added": points,
            "current_points": new_points,
            "message": "Loyalty points updated successfully"
        }
    
    except Exception as e:
        if conn:
            conn.rollback()
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()
