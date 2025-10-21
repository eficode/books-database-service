"""
Script to migrate the database with the new category column
"""
import sys
import os
import sqlite3
import re

# Add parent directory to path so we can import from fastapi_demo
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi_demo.database import engine, SQLALCHEMY_DATABASE_URL

def migrate_database():
    """Add the category column to the books table if it doesn't exist"""
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
    else:
        print("Column 'category' already exists.")
        
    # Add favorite column if it doesn't exist
    if 'favorite' not in column_names:
        print("Adding 'favorite' column to books table...")
        cursor.execute("ALTER TABLE books ADD COLUMN favorite BOOLEAN DEFAULT 0")
        conn.commit()
        print("Favorite column added successfully.")
    else:
        print("Column 'favorite' already exists.")
    
    conn.close()

if __name__ == "__main__":
    migrate_database()