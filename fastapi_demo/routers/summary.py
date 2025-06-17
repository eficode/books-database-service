from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dependencies import get_current_user
from ..schemas import User

router = APIRouter()

@router.get("/summary/books-by-writers")
def get_books_summary_by_writers(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    books = db.query(Book).filter(Book.user_id == current_user.id).all()
    if not books:
        return {"message": "No books available"}
    writer_summary = {}
    for book in books:
        if book.author in writer_summary:
            writer_summary[book.author] += 1
        else:
            writer_summary[book.author] = 1
    return {"writers": [{"writer": writer, "book_count": count} for writer, count in writer_summary.items()]}
