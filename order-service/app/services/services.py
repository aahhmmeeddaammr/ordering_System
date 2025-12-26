from ..utils.db_connection import get_db_connection
import requests
import os
from datetime import datetime

def create_order(customer_id, products, total_amount):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        
        cursor.execute("SELECT customer_id FROM customers WHERE customer_id = %s", (customer_id,))
        if not cursor.fetchone():
            return {"success": False, "error": f"Customer {customer_id} not found"}
        
        
        cursor.execute(
            "INSERT INTO orders (customer_id, total_amount, status) VALUES (%s, %s, %s)",
            (customer_id, total_amount, "pending")
        )
        conn.commit()
        
        order_id = cursor.lastrowid
        
        
        for product in products:
            product_id = product.get("product_id")
            quantity = product.get("quantity")
            
            
            try:
                inventory_url = os.getenv("INVENTORY_URL", "http://localhost:5002")
                response = requests.get(
                    f"{inventory_url}/api/inventory/check/{product_id}",
                    timeout=5
                )
                
                if response.ok:
                    inventory_data = response.json()
                    unit_price = inventory_data.get("unit_price", 0)
                else:
                    unit_price = 0
            except:
                unit_price = 0
            
            
            cursor.execute(
                "INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (%s, %s, %s, %s)",
                (order_id, product_id, quantity, unit_price)
            )
        
        conn.commit()
        
        return {
            "success": True,
            "order_id": order_id,
            "customer_id": customer_id,
            "total_amount": float(total_amount),
            "status": "pending",
            "timestamp": datetime.now().isoformat(),
            "message": "Order created successfully"
        }
    
    except Exception as e:
        if conn:
            conn.rollback()
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()

def get_order_details(order_id):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        
        cursor.execute("SELECT * FROM orders WHERE order_id = %s", (order_id,))
        order = cursor.fetchone()
        
        if not order:
            return {"success": False, "error": "Order not found"}
        
        
        cursor.execute(
            "SELECT order_item_id, product_id, quantity, unit_price FROM order_items WHERE order_id = %s",
            (order_id,)
        )
        items = cursor.fetchall()
        
        
        enriched_items = []
        inventory_url = os.getenv("INVENTORY_URL", "http://localhost:5002")
        
        for item in items:
            product_name = f"Product #{item['product_id']}"  
            try:
                response = requests.get(
                    f"{inventory_url}/api/inventory/check/{item['product_id']}",
                    timeout=5
                )
                if response.ok:
                    inventory_data = response.json()
                    if inventory_data.get("success"):
                        product_name = inventory_data.get("product_name", product_name)
            except:
                pass  
            
            enriched_items.append({
                "item_id": item["order_item_id"],
                "product_id": item["product_id"],
                "product_name": product_name,
                "quantity": item["quantity"],
                "unit_price": float(item["unit_price"])
            })
        
        return {
            "success": True,
            "order_id": order["order_id"],
            "customer_id": order["customer_id"],
            "total_amount": float(order["total_amount"]),
            "status": order["status"],
            "order_date": str(order["order_date"]),
            "items": enriched_items
        }
    
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()

def get_customer_orders(customer_id):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute(
            "SELECT order_id, customer_id, total_amount, status, order_date FROM orders WHERE customer_id = %s",
            (customer_id,)
        )
        orders = cursor.fetchall()
        
        return {
            "success": True,
            "customer_id": customer_id,
            "orders": [
                {
                    "order_id": order["order_id"],
                    "customer_id": order["customer_id"],
                    "total_amount": float(order["total_amount"]),
                    "status": order["status"],
                    "order_date": str(order["order_date"])
                }
                for order in orders
            ]
        }
    
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()