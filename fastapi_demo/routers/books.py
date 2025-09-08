from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.models import Book
from fastapi_demo.database import get_db
from fastapi_demo.dtos import BookInfo
import re

router = APIRouter()

ISBN_REGEX = r'^(97(8|9))?\d{9}(\d|X)$'

@router.get("/books/isbn/{isbn}", response_model=BookInfo)
def read_book_by_isbn(isbn: str, db: Session = Depends(get_db)):
    if not isbn or not re.match(ISBN_REGEX, isbn):
        raise HTTPException(status_code=400, detail="Invalid ISBN")
    book = db.query(Book).filter(Book.isbn == isbn).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return BookInfo(**book.__dict__)