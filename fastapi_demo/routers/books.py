from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models import Book

router = APIRouter()

@router.get("/best_selling_books/")
def get_best_selling_books(genre: Optional[str] = None, sort_by: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Book)
    if genre:
        query = query.filter(Book.genre == genre)
    if sort_by == 'sales_rank':
        query = query.order_by(Book.sales_rank.desc())
    books = query.all()
    if not books:
        return {"message": "No best-selling books are available"}
    return {"books": [{"title": book.title, "author": book.author, "sales_rank": book.sales_rank} for book in books]}