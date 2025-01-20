from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book

router = APIRouter()

@router.delete("/books/red")
def delete_red_books(db: Session = Depends(get_db)):
    red_books = db.query(Book).filter(Book.color == 'red').all()
    if not red_books:
        return {"detail": "No red books found"}
    for book in red_books:
        db.delete(book)
    db.commit()
    return {"detail": "All red books removed"}
