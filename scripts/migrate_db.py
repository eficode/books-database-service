"""
Script to migrate the database with new columns (category, favorite, price, stock)
"""
import sys
import os
import sqlite3
import re

# Add parent directory to path so we can import from fastapi_demo
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi_demo.database import engine, SQLALCHEMY_DATABASE_URL

def migrate_database():
    """Add the category, favorite, price, and stock columns to the books table if they don't exist"""
    # Extract database path from SQLALCHEMY_DATABASE_URL
    # SQLite URL format: sqlite:///path/to/database.db
    match = re.search(r'sqlite:///(.+)', SQLALCHEMY_DATABASE_URL)
    if match:
        db_path = match.group(1)
    else:
        db_path = 'test.db'
        
    print(f"Migrating database at: {db_path}")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Check if the column exists
    cursor.execute("PRAGMA table_info(books)")
    columns = cursor.fetchall()
    column_names = [column[1] for column in columns]
    
    if 'category' not in column_names:
        print("Adding 'category' column to books table...")
        cursor.execute("ALTER TABLE books ADD COLUMN category TEXT DEFAULT 'Fiction'")
        conn.commit()
        print("Column added successfully.")
        # Refresh column names
        cursor.execute("PRAGMA table_info(books)")
        columns = cursor.fetchall()
        column_names = [column[1] for column in columns]
    else:
        print("Column 'category' already exists.")
        
    # Add favorite column if it doesn't exist
    if 'favorite' not in column_names:
        print("Adding 'favorite' column to books table...")
        cursor.execute("ALTER TABLE books ADD COLUMN favorite BOOLEAN DEFAULT 0")
        conn.commit()
        print("Favorite column added successfully.")
        # Refresh column names
        cursor.execute("PRAGMA table_info(books)")
        columns = cursor.fetchall()
        column_names = [column[1] for column in columns]
    else:
        print("Column 'favorite' already exists.")
    
    # Add price column if it doesn't exist
    if 'price' not in column_names:
        print("Adding 'price' column to books table...")
        cursor.execute("ALTER TABLE books ADD COLUMN price REAL DEFAULT 9.99")
        conn.commit()
        print("Price column added successfully.")
        # Refresh column names
        cursor.execute("PRAGMA table_info(books)")
        columns = cursor.fetchall()
        column_names = [column[1] for column in columns]
    else:
        print("Column 'price' already exists.")
    
    # Add stock column if it doesn't exist
    if 'stock' not in column_names:
        print("Adding 'stock' column to books table...")
        cursor.execute("ALTER TABLE books ADD COLUMN stock INTEGER DEFAULT 10")
        conn.commit()
        print("Stock column added successfully.")
    else:
        print("Column 'stock' already exists.")
    
    conn.close()

if __name__ == "__main__":
    migrate_database()