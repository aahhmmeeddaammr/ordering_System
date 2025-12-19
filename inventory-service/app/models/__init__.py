from ..utils.db_connection import execute_query, execute_update

class Inventory:
    
    @staticmethod
    def get_by_id(product_id):
        query = "SELECT * FROM inventory WHERE product_id = %s"
        result = execute_query(query, (product_id,))
        return result[0] if result else None
    
    @staticmethod
    def get_all():
        query = "SELECT * FROM inventory"
        return execute_query(query)
    
    @staticmethod
    def create(product_name, quantity_available, unit_price):
        query = "INSERT INTO inventory (product_name, quantity_available, unit_price) VALUES (%s, %s, %s)"
        return execute_update(query, (product_name, quantity_available, unit_price))
    
    @staticmethod
    def update_quantity(product_id, quantity):
        query = "UPDATE inventory SET quantity_available = %s, last_updated = CURRENT_TIMESTAMP WHERE product_id = %s"
        return execute_update(query, (quantity, product_id))
    
    @staticmethod
    def update_price(product_id, unit_price):
        query = "UPDATE inventory SET unit_price = %s, last_updated = CURRENT_TIMESTAMP WHERE product_id = %s"
        return execute_update(query, (unit_price, product_id))
    
    @staticmethod
    def decrease_quantity(product_id, quantity):
        query = """
            UPDATE inventory 
            SET quantity_available = quantity_available - %s, 
                last_updated = CURRENT_TIMESTAMP 
            WHERE product_id = %s AND quantity_available >= %s
        """
        return execute_update(query, (quantity, product_id, quantity))
    
    @staticmethod
    def increase_quantity(product_id, quantity):
        query = """
            UPDATE inventory 
            SET quantity_available = quantity_available + %s, 
                last_updated = CURRENT_TIMESTAMP 
            WHERE product_id = %s
        """
        return execute_update(query, (quantity, product_id))
    
    @staticmethod
    def check_availability(product_id, quantity):
        product = Inventory.get_by_id(product_id)
        if product:
            return product["quantity_available"] >= quantity
        return False
