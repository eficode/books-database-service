from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import asc, desc
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/sort", response_model=List[BookInfo])
def sort_books(order: str = Query('asc', regex='^(asc|desc)$'), db: Session = Depends(get_db)):
    if order == 'asc':
        books = db.query(Book).order_by(asc(Book.title)).all()
    else:
        books = db.query(Book).order_by(desc(Book.title)).all()
    return [BookInfo(**book.__dict__) for book in books]