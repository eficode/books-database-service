from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book

router = APIRouter()

@router.get("/books/search")
def search_books(title: str = None, author: str = None, isbn: str = None, db: Session = Depends(get_db)):
    query = db.query(Book)
    if title:
        query = query.filter(Book.title.ilike(f"%{title}%"))
    if author:
        query = query.filter(Book.author.ilike(f"%{author}%"))
    if isbn:
        query = query.filter(Book.isbn == isbn)
    books = query.all()
    if not books:
        raise HTTPException(status_code=404, detail="No books found")
    return books
