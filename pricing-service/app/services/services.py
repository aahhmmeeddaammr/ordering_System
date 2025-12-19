from ..utils.db_connection import get_db_connection
import requests
import os

def calculate_order_pricing(products, region="Egypt"):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        items_breakdown = []
        subtotal = 0.0
        total_discount = 0.0
        
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
                    unit_price = float(inventory_data.get("unit_price", 0))
                    product_name = inventory_data.get("product_name", "")
                else:
                    continue
            except:
                continue
            
            cursor.execute(
                "SELECT discount_percentage FROM pricing_rules WHERE product_id = %s AND min_quantity <= %s ORDER BY min_quantity DESC LIMIT 1",
                (product_id, quantity)
            )
            discount_rule = cursor.fetchone()
            discount_percentage = float(discount_rule["discount_percentage"]) if discount_rule else 0.0
            
            item_subtotal = unit_price * quantity
            discount_amount = item_subtotal * (discount_percentage / 100)
            item_total = item_subtotal - discount_amount
            
            subtotal += item_subtotal
            total_discount += discount_amount
            
            items_breakdown.append({
                "product_id": product_id,
                "product_name": product_name,
                "quantity": quantity,
                "unit_price": unit_price,
                "item_subtotal": round(item_subtotal, 2),
                "discount_percentage": discount_percentage,
                "discount_amount": round(discount_amount, 2),
                "item_total": round(item_total, 2)
            })
        
        cursor.execute(
            "SELECT tax_rate FROM tax_rates WHERE region = %s",
            (region,)
        )
        tax_result = cursor.fetchone()
        
        if not tax_result:
            tax_rate = 10.0
        else:
            tax_rate = float(tax_result["tax_rate"])
        
        after_discount = subtotal - total_discount
        tax_amount = after_discount * (tax_rate / 100)
        final_total = after_discount + tax_amount
        
        return {
            "success": True,
            "items": items_breakdown,
            "subtotal": round(subtotal, 2),
            "total_discount": round(total_discount, 2),
            "after_discount": round(after_discount, 2),
            "tax_rate": tax_rate,
            "tax_amount": round(tax_amount, 2),
            "final_total": round(final_total, 2),
            "region": region
        }
    
    except Exception as e:
        return {"success": False, "error": str(e)}
    finally:
        if conn:
            conn.close()
