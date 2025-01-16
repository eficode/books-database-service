from fastapi import APIRouter, Depends
from ..email import send_email
from ..time import get_current_time
from ..database import get_db
from ..models import Book
from sqlalchemy.orm import Session

router = APIRouter()

@router.get('/schedule-email-notification')
def schedule_email_notification(db: Session = Depends(get_db)):
    current_time = get_current_time()
    if current_time == '08:00 AM':
        books = db.query(Book).order_by(Book.sales.desc()).all()
        book_list = '\n'.join([f'{book.title}: {book.sales} sales' for book in books])
        send_email('sales_manager@example.com', book_list)
    return {'message': 'Checked schedule for email notification'}