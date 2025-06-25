from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from fastapi_demo.database import get_db
from fastapi_demo.models import Book
from fastapi_demo.dtos import AuthorBooks, BookInfo

router = APIRouter()

@router.get('/books/by-author', response_model=List[AuthorBooks])
def get_books_by_author(db: Session = Depends(get_db)):
    try:
        books_by_author = db.query(Book.author, func.json_agg(Book).label('books')).group_by(Book.author).all()
        return [{'author': author, 'books': [BookInfo(**book) for book in books]} for author, books in books_by_author]
    except Exception as e:
        raise HTTPException(status_code=503, detail='Books cannot be fetched')

@router.get('/books/rank-by-author')
def rank_books_by_author():
    raise HTTPException(status_code=503, detail='Ranking is not available')
