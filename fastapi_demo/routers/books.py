from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get('/books/search', response_model=List[BookInfo])
def search_books(author: str, db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.author.ilike(f'%{author}%')).all()
    if not books:
        raise HTTPException(status_code=404, detail='No books found for the given author')
    return [BookInfo.from_orm(book) for book in books]
