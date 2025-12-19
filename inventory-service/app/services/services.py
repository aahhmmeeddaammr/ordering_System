from ..utils.db_connection import get_db_connection

def get_inventory_details(product_id):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute(
            "SELECT product_id, product_name, quantity_available, unit_price, last_updated FROM inventory WHERE product_id = %s",
            (product_id,)
        )
        product = cursor.fetchone()
        
        if not product:
            return {"success": False, "error": f"Product {product_id} not found"}
        
        return {
            "success": True,
            "product_id": product["product_id"],
            "product_name": product["product_name"],
            "quantity_available": product["quantity_available"],
            "unit_price": float(product["unit_price"]),
            "status": "available" if product["quantity_available"] > 0 else "out_of_stock",
            "last_updated": str(product["last_updated"])
        }
    
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()

def get_all_products():
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute(
            "SELECT product_id, product_name, quantity_available, unit_price FROM inventory"
        )
        products = cursor.fetchall()
        
        if not products:
            return {"success": True, "products": []}
        
        return {
            "success": True,
            "products": [
                {
                    "product_id": p["product_id"],
                    "product_name": p["product_name"],
                    "quantity_available": p["quantity_available"],
                    "unit_price": float(p["unit_price"]),
                    "status": "available" if p["quantity_available"] > 0 else "out_of_stock"
                }
                for p in products
            ]
        }
    
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()

def update_inventory(product_id, quantity):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Check current quantity
        cursor.execute(
            "SELECT quantity_available FROM inventory WHERE product_id = %s",
            (product_id,)
        )
        product = cursor.fetchone()
        
        if not product:
            return {"success": False, "error": f"Product {product_id} not found"}
        
        if product["quantity_available"] < quantity:
            return {
                "success": False,
                "error": f"Insufficient stock. Available: {product['quantity_available']}, Requested: {quantity}"
            }
        
        # Update inventory
        cursor.execute(
            "UPDATE inventory SET quantity_available = quantity_available - %s WHERE product_id = %s",
            (quantity, product_id)
        )
        conn.commit()
        
        # Get updated inventory
        cursor.execute(
            "SELECT quantity_available FROM inventory WHERE product_id = %s",
            (product_id,)
        )
        updated = cursor.fetchone()
        
        return {
            "success": True,
            "product_id": product_id,
            "quantity_deducted": quantity,
            "remaining_quantity": updated["quantity_available"],
            "message": "Inventory updated successfully"
        }
    
    except Exception as e:
        if conn:
            conn.rollback()
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()
