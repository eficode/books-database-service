from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book

router = APIRouter()

@router.get('/books/by-author')
def get_books_by_author(db: Session = Depends(get_db)):
    books = db.query(Book).all()
    authors = {}
    for book in books:
        if book.author not in authors:
            authors[book.author] = []
        authors[book.author].append({
            'id': book.id,
            'title': book.title
        })
    return {'authors': [{'author': author, 'books': books} for author, books in authors.items()]}