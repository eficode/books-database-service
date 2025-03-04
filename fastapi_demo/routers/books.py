from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
import logging

router = APIRouter()

# Configure logging
logging.basicConfig(level=logging.INFO)

@router.delete("/books/test")
def delete_test_books(db: Session = Depends(get_db), user: str = Depends(get_current_user)):
    if not user.is_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")
    test_books = db.query(Book).filter(Book.title.like('TEST%')).all()
    if not test_books:
        return {"detail": "No test books found"}
    for book in test_books:
        db.delete(book)
        logging.info(f"Deleted test book: {book.title}, ID: {book.id}")
    db.commit()
    return {"detail": "All test books removed"}
