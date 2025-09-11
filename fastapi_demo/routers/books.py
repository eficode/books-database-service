from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get('/books/search', response_model=List[BookInfo])
def search_books(
    title: Optional[str] = Query(None),
    author: Optional[str] = Query(None),
    isbn: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    query = db.query(Book)
    if title:
        query = query.filter(Book.title.ilike(f'%{title}%'))
    if author:
        query = query.filter(Book.author.ilike(f'%{author}%'))
    if isbn:
        query = query.filter(Book.isbn == isbn)
    books = query.all()
    if not books:
        raise HTTPException(status_code=404, detail='No books found')
    return [BookInfo.from_orm(book) for book in books]
