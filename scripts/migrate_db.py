"""
Script to migrate the database with the new category column
"""
import sys
import os
import sqlite3

# Add parent directory to path so we can import from fastapi_demo
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi_demo.database import engine

def migrate_database():
    """Add the category column to the books table if it doesn't exist"""
    conn = sqlite3.connect('test.db')
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
    
    conn.close()

if __name__ == "__main__":
    migrate_database()