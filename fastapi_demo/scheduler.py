from datetime import datetime
import smtplib
from email.mime.text import MIMEText
import pytz
from apscheduler.schedulers.background import BackgroundScheduler
from sqlalchemy.orm import Session
from .database import get_db
from .models import Book

scheduler = BackgroundScheduler(timezone=pytz.timezone('EET'))


def send_sales_report_email():
    try:
        db: Session = next(get_db())
        most_sold_books = db.query(Book).order_by(Book.sales.desc()).limit(10).all()
        least_sold_books = db.query(Book).order_by(Book.sales.asc()).limit(10).all()
        report = {
            "most_sold_books": [
                {"title": book.title, "author": book.author, "sales": book.sales}
                for book in most_sold_books
            ],
            "least_sold_books": [
                {"title": book.title, "author": book.author, "sales": book.sales}
                for book in least_sold_books
            ]
        }
        email_content = f"Most Sold Books: {report['most_sold_books']}\n\nLeast Sold Books: {report['least_sold_books']}"
        msg = MIMEText(email_content)
        msg['Subject'] = 'Daily Sales Report'
        msg['From'] = 'noreply@bookbridge.com'
        msg['To'] = 'sales.manager@bookbridge.com'
        with smtplib.SMTP('smtp.example.com') as server:
            server.login('user', 'password')
            server.sendmail(msg['From'], [msg['To']], msg.as_string())
    except smtplib.SMTPException as e:
        print(f"Failed to send email: {e}")


scheduler.add_job(send_sales_report_email, 'cron', hour=8, minute=0)
scheduler.start()
