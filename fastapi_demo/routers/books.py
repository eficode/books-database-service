from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models import Book
from ..schemas import BookInfo

router = APIRouter()

@router.get("/books/search/", response_model=List[BookInfo])
def search_books(title: Optional[str] = None, author: Optional[str] = None, genre: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Book)
    if title:
        query = query.filter(Book.title.ilike(f"%{title}%"))
    if author:
        query = query.filter(Book.author.ilike(f"%{author}%"))
    if genre:
        query = query.filter(Book.genre.ilike(f"%{genre}%"))
    books = query.all()
    if not books:
        return {"message": "No results found"}
    return books