from sqlalchemy.orm import Session
from .models import Book
import requests

# Database Query for Least Sold Books
def get_least_sold_books(db: Session):
    return db.query(Book).order_by(Book.sales.asc()).limit(10).all()

# Report Generation
def generate_report(books):
    report = 'Title, Author, Sales\n'
    for book in books:
        report += f'{book.title}, {book.author}, {book.sales}\n'
    return report

# Email Sending
def send_email(to, subject, body):
    email_data = {
        'to': to,
        'subject': subject,
        'body': body
    }
    response = requests.post('http://localhost:8000/email/send', json=email_data)
    return response
