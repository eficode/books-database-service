import schedule
import time
from .email_service import send_email
from .database import get_db
from .models import Book

# Function to fetch most sold books
def fetch_most_sold_books(db):
    return db.query(Book).order_by(Book.sales_volume.desc()).all()

# Function to send daily email
def send_daily_email():
    db = next(get_db())
    most_sold_books = fetch_most_sold_books(db)
    email_content = "\n".join([f"{book.title} by {book.author} - {book.sales_volume} sales" for book in most_sold_books])
    send_email(to="sales_manager@example.com", subject="Daily Most Sold Books", body=email_content)

# Schedule the task
schedule.every().day.at("08:00").do(send_daily_email)

while True:
    schedule.run_pending()
    time.sleep(1)