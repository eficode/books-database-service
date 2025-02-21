from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/books/search", response_model=List[BookInfo])
def search_books(title: Optional[str] = None, author: Optional[str] = None, publication_date: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Book)
    if title:
        query = query.filter(Book.title.ilike(f"%{title}%"))
    if author:
        query = query.filter(Book.author.ilike(f"%{author}%"))
    if publication_date:
        query = query.filter(Book.publication_date == publication_date)
    results = query.all()
    if not results:
        return {"message": "No books found"}
    return [BookInfo(**book.__dict__) for book in results]
