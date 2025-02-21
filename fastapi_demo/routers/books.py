from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models import Book

router = APIRouter()

@router.get("/books/search", response_model=List[Book])
def search_books(
    title: Optional[str] = Query(None),
    author: Optional[str] = Query(None),
    publication_date: Optional[str] = Query(None),
    isbn: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    query = db.query(Book)
    if title:
        query = query.filter(Book.title.ilike(f"%{title}%"))
    if author:
        query = query.filter(Book.author.ilike(f"%{author}%"))
    if publication_date:
        query = query.filter(Book.publication_date == publication_date)
    if isbn:
        query = query.filter(Book.isbn == isbn)
    results = query.all()
    if not results:
        raise HTTPException(status_code=404, detail="No matching books found")
    return results
