from ..utils.db_connection import execute_query, execute_update

class Customer:
    
    @staticmethod
    def get_by_id(customer_id):
        query = "SELECT * FROM customers WHERE customer_id = %s"
        result = execute_query(query, (customer_id,))
        return result[0] if result else None
    
    @staticmethod
    def get_all():
        query = "SELECT * FROM customers"
        return execute_query(query)
    
    @staticmethod
    def create(name, email, phone, loyalty_points=0):
        query = "INSERT INTO customers (name, email, phone, loyalty_points) VALUES (%s, %s, %s, %s)"
        return execute_update(query, (name, email, phone, loyalty_points))
    
    @staticmethod
    def update(customer_id, name=None, email=None, phone=None, loyalty_points=None):
        updates = []
        params = []
        
        if name:
            updates.append("name = %s")
            params.append(name)
        if email:
            updates.append("email = %s")
            params.append(email)
        if phone:
            updates.append("phone = %s")
            params.append(phone)
        if loyalty_points is not None:
            updates.append("loyalty_points = %s")
            params.append(loyalty_points)
        
        if not updates:
            return False
        
        params.append(customer_id)
        query = f"UPDATE customers SET {', '.join(updates)} WHERE customer_id = %s"
        return execute_update(query, params)
    
    @staticmethod
    def get_by_email(email):
        query = "SELECT * FROM customers WHERE email = %s"
        result = execute_query(query, (email,))
        return result[0] if result else None
