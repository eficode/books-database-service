from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book
from fastapi_demo.schemas import BookInfo

router = APIRouter()

@router.get("/books/search", response_model=BookInfo)
def search_book(isbn: str, db: Session = Depends(get_db)):
    if not isbn.isdigit() or len(isbn) not in [10, 13]:
        raise HTTPException(status_code=400, detail="Invalid ISBN format")
    book = db.query(Book).filter(Book.isbn == isbn).first()
    if book is None:
        raise HTTPException(status_code=404, detail="No results found")
    return BookInfo(**book.__dict__)