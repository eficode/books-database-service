from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/top-selling-sci-fi", response_model=List[BookInfo])
def get_top_selling_sci_fi_books(db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.genre == 'Sci-Fi').order_by(Book.sales.desc()).all()
    return [BookInfo(**book.__dict__) for book in books]
