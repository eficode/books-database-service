from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
import isbnlib
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/search", response_model=BookInfo)
def search_book_by_isbn(isbn: str = Query(...), db: Session = Depends(get_db)):
    if not isbnlib.is_isbn10(isbn) and not isbnlib.is_isbn13(isbn):
        raise HTTPException(status_code=400, detail="Invalid ISBN format")
    book = db.query(Book).filter(Book.isbn == isbn).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return BookInfo(**book.__dict__)