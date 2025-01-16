from apscheduler.schedulers.background import BackgroundScheduler
from .database import SessionLocal
from .models import Book, SalesData
from .email_service import send_email

scheduler = BackgroundScheduler()

def fetch_and_send_most_sold_books():
    db = SessionLocal()
    try:
        sales_data = db.query(SalesData).order_by(SalesData.sales.desc()).all()
        books = []
        for data in sales_data:
            book = db.query(Book).filter(Book.id == data.book_id).first()
            if book:
                books.append({"title": book.title, "author": book.author, "sales": data.sales})
        send_email(books)
    finally:
        db.close()

scheduler.add_job(fetch_and_send_most_sold_books, 'cron', hour=8, minute=0)

def start_scheduler():
    scheduler.start()