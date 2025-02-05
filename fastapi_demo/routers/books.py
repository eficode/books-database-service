from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/best-selling/", response_model=List[BookInfo])
def search_best_selling_books(
    genre: Optional[str] = None,
    publication_date: Optional[str] = None,
    author: Optional[str] = None,
    sort_by: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Book)
    if genre:
        query = query.filter(Book.genre == genre)
    if publication_date:
        query = query.filter(Book.publication_date == publication_date)
    if author:
        query = query.filter(Book.author == author)
    if sort_by:
        if sort_by == 'sales':
            query = query.order_by(Book.sales.desc())
        elif sort_by == 'ratings':
            query = query.order_by(Book.ratings.desc())
        else:
            raise HTTPException(status_code=400, detail="Invalid sort criteria")
    books = query.all()
    if not books:
        return {"message": "No results found"}
    return books
