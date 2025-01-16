from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..email_service import send_email, generate_email_content
from typing import List

router = APIRouter()

@router.post("/schedule-email")
def schedule_email(db: Session = Depends(get_db)):
    most_sold_books = db.query(Book).order_by(Book.sales.desc()).all()
    email_content = generate_email_content(most_sold_books)
    send_email("sales_manager@example.com", "Most Sold Books", email_content)
    return {"detail": "Email scheduled"}

@router.get("/most-sold-books", response_model=List[Book])
def get_most_sold_books(db: Session = Depends(get_db)):
    books = db.query(Book).order_by(Book.sales.desc()).all()
    return books
