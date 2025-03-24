from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/search", response_model=List[BookInfo])
def search_books(color: str, type: str, db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.color == color, Book.type == type).all()
    if not books:
        raise HTTPException(status_code=404, detail="No blue test books found")
    return [BookInfo(**book.__dict__) for book in books]
