from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book, Sales
from ..dtos import BookInfo
from typing import List, Optional

router = APIRouter()

@router.get('/top-selling-books/', response_model=List[BookInfo])
def get_top_selling_books(
    date_range: Optional[str] = Query(None),
    genre: Optional[str] = Query(None),
    author: Optional[str] = Query(None),
    sort_by: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    query = db.query(Book).join(Sales)
    if date_range:
        start_date, end_date = date_range.split(' to ')
        query = query.filter(Sales.date_sold.between(start_date, end_date))
    if genre:
        query = query.filter(Book.genre == genre)
    if author:
        query = query.filter(Book.author == author)
    if sort_by:
        query = query.order_by(getattr(Sales, sort_by))
    books = query.all()
    return [BookInfo.from_orm(book) for book in books]
