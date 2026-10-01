import mysql.connector

db_config = {
    "host": "localhost",
    "user": "root",
    "password": "1234",
    "database": "revenda"
}

def get_connection():
    return mysql.connector.connect(**db_config)