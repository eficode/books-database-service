from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

SUPPORTED_LANGUAGES = ['en', 'es', 'fr', 'de']  # Example supported languages

@router.get('/books/best-selling', response_model=List[BookInfo])
def search_best_selling_books(language: str, db: Session = Depends(get_db)):
    if language not in SUPPORTED_LANGUAGES:
        raise HTTPException(status_code=400, detail='Language not supported')

    books = db.query(Book).filter(Book.language == language).order_by(Book.sales.desc()).all()
    if not books:
        raise HTTPException(status_code=404, detail='No best-selling books found for the specified language')
    return [BookInfo(**book.__dict__) for book in books]
