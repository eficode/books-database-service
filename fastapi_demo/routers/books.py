from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo
from typing import List

router = APIRouter()

@router.get('/books/', response_model=List[BookInfo])
def list_books(db: Session = Depends(get_db)):
    try:
        books = db.query(Book).all()
        if not books:
            raise HTTPException(status_code=404, detail='No books available')
        for book in books:
            if book.title is None or book.author is None or book.price is None:
                raise HTTPException(status_code=400, detail='Some book information is missing')
        return [BookInfo(**book.__dict__) for book in books]
    except Exception as e:
        raise HTTPException(status_code=500, detail='Books could not be loaded')
