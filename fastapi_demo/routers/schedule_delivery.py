from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Delivery, User, Book
from datetime import datetime, timedelta
from ..email_service import send_email
import logging

router = APIRouter()

@router.post("/schedule-delivery/")
def schedule_delivery(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    # Check if the user's favorites list is empty
    if not user.favorites:
        logging.info(f"User {user_id} has no favorites for delivery.")
        return {"message": "No books available for delivery"}
    # Select a book from the user's curated favorites list
    favorite_book_ids = [int(id) for id in user.favorites.split(',') if id.isdigit()]
    book = db.query(Book).filter(Book.id.in_(favorite_book_ids)).order_by(func.random()).first()
    if not book:
        logging.info(f"User {user_id} has no valid favorite books for delivery.")
        return {"message": "No books available for delivery"}
    # Schedule the delivery
    delivery_date = datetime.now() + timedelta(days=30)
    delivery = Delivery(user_id=user_id, book_id=book.id, delivery_date=delivery_date)
    db.add(delivery)
    db.commit()
    return {"message": "Delivery scheduled successfully"}

@router.post("/notify-delivery/")
def notify_delivery(user_id: int, book_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    book = db.query(Book).filter(Book.id == book_id).first()
    if not user or not book:
        raise HTTPException(status_code=404, detail="User or Book not found")
    # Check if the user's email is valid
    if '@' not in user.email:
        logging.error(f"Invalid email address for user {user_id}: {user.email}")
        return {"message": "Invalid email address"}
    # Send email notification
    send_email(user.email, f"Your monthly book delivery: {book.title}", f"Your book '{book.title}' has been shipped to {user.address}.")
    return {"message": "Notification sent successfully"}
