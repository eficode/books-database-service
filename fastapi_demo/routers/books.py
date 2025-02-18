from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/top-rated", response_model=List[BookInfo])
def get_top_rated_books(db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.category == 'Software Development').order_by(Book.rating.desc()).limit(10).all()
    if not books:
        raise HTTPException(status_code=404, detail="No top-rated software development books found")
    return [BookInfo(**book.__dict__) for book in books]
