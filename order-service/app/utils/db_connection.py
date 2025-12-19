import mysql.connector
from mysql.connector import Error
import os

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASS", ""),
            database=os.getenv("DB_NAME", "ecommerce_system")
        )
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

def close_db_connection(connection):
    if connection and connection.is_connected():
        connection.close()

def execute_query(query, params=None):
    connection = get_db_connection()
    if not connection:
        return None
    
    try:
        cursor = connection.cursor(dictionary=True)
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        return results
    except Error as e:
        print(f"Error executing query: {e}")
        return None
    finally:
        close_db_connection(connection)

def execute_update(query, params=None):
 
    connection = get_db_connection()
    if not connection:
        return False
    
    try:
        cursor = connection.cursor()
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        connection.commit()
        last_id = cursor.lastrowid
        cursor.close()
        return last_id if last_id > 0 else True
    except Error as e:
        print(f"Error executing update: {e}")
        connection.rollback()
        return False
    finally:
        close_db_connection(connection)
