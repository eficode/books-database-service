from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/search", response_model=List[BookInfo])
def search_books_by_color(color: str, db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.color == color).all()
    if not books:
        raise HTTPException(status_code=404, detail=f"No books found with the color '{color}'")
    return [BookInfo(**book.__dict__) for book in books]
