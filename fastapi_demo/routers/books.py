from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/isbn/{isbn}", response_model=BookInfo)
def read_book_by_isbn(isbn: str, db: Session = Depends(get_db)):
    if not isbn:
        raise HTTPException(status_code=400, detail="Invalid ISBN")
    if len(isbn) not in [10, 13] or not isbn.isdigit():
        raise HTTPException(status_code=400, detail="Invalid ISBN")
    book = db.query(Book).filter(Book.isbn == isbn).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return BookInfo(**book.__dict__)