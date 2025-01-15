from sqlalchemy.orm import Session
from sqlalchemy import func
import smtplib
from email.mime.text import MIMEText
from ..models import Book, Sales


def get_most_sold_books(db: Session):
    return db.query(Book.title, func.sum(Sales.quantity).label('total_sales'))\
        .join(Sales, Sales.book_id == Book.id)\
        .group_by(Book.title)\
        .order_by(func.sum(Sales.quantity).desc())\
        .all()


def generate_report(db: Session):
    most_sold_books = get_most_sold_books(db)
    report = "Most Sold Books:\n"
    for book in most_sold_books:
        report += f"Title: {book.title}, Sales: {book.total_sales}\n"
    return report


def send_email(report: str, recipient: str):
    msg = MIMEText(report)
    msg['Subject'] = 'Daily Report of Most Sold Books'
    msg['From'] = 'noreply@bookbridge.com'
    msg['To'] = recipient
    with smtplib.SMTP('smtp.example.com') as server:
        server.starttls()
        server.login('username', 'password')
        server.sendmail(msg['From'], [msg['To']], msg.as_string())


def send_daily_report(db: Session):
    report = generate_report(db)
    send_email(report, 'marketing@bookbridge.com')
