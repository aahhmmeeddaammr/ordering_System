from ..utils.db_connection import execute_query, execute_update

class Order:
    
    @staticmethod
    def create_order(customer_id, total_amount):
        query = "INSERT INTO orders (customer_id, total_amount) VALUES (%s, %s)"
        return execute_update(query, (customer_id, total_amount))
    
    @staticmethod
    def get_order_by_id(order_id):
        query = "SELECT * FROM orders WHERE order_id = %s"
        result = execute_query(query, (order_id,))
        return result[0] if result else None
    
    @staticmethod
    def get_orders_by_customer(customer_id):
        query = "SELECT * FROM orders WHERE customer_id = %s ORDER BY created_at DESC"
        return execute_query(query, (customer_id,))
    
    @staticmethod
    def get_all_orders():
        query = "SELECT * FROM orders ORDER BY created_at DESC"
        return execute_query(query)
    
    @staticmethod
    def add_order_item(order_id, product_id, quantity, price):
        query = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (%s, %s, %s, %s)"
        return execute_update(query, (order_id, product_id, quantity, price))
    
    @staticmethod
    def get_order_items(order_id):
        query = "SELECT * FROM order_items WHERE order_id = %s"
        return execute_query(query, (order_id,))
    
    @staticmethod
    def update_order_total(order_id, total_amount):
        query = "UPDATE orders SET total_amount = %s WHERE order_id = %s"
        return execute_update(query, (total_amount, order_id))
