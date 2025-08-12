from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get('/books/search', response_model=List[BookInfo])
def search_books(genre: str = Query(None), keyword: str = Query(None), db: Session = Depends(get_db)):
    query = db.query(Book)
    if genre:
        query = query.filter(Book.genre == genre)
    if keyword:
        query = query.filter(or_(Book.title.ilike(f'%{keyword}%'), Book.author.ilike(f'%{keyword}%')))
    books = query.all()
    if not books:
        if genre:
            raise HTTPException(status_code=404, detail=f'No books found in the {genre} genre.')
        if keyword:
            raise HTTPException(status_code=404, detail=f'No books found matching the keyword {keyword}.')
    return [BookInfo.from_orm(book) for book in books]
