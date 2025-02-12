from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/search", response_model=List[BookInfo])
def search_books(db: Session = Depends(get_db)):
    try:
        books = db.query(Book).filter(Book.pages > 1000).all()
        if not books:
            raise HTTPException(status_code=404, detail="No books found with more than 1000 pages")
        return [BookInfo(**book.__dict__) for book in books]
    except Exception as e:
        raise HTTPException(status_code=500, detail="The search could not be completed")
