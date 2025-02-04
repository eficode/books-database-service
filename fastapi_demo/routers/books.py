from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/search/", response_model=List[BookInfo])
def search_books(colors: str, db: Session = Depends(get_db)):
    color_list = colors.split(",")
    books = db.query(Book).filter(Book.color.in_(color_list)).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books found with the specified color(s)")
    return [BookInfo(**book.__dict__) for book in books]
