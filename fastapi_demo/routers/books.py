from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book
from fastapi_demo.auth import get_current_user, User
import logging
from datetime import datetime

router = APIRouter()

@router.delete("/books/{book_id}")
def delete_book(book_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not current_user.is_authorized_to_remove_books:
        raise HTTPException(status_code=403, detail="Not authorized to remove books")
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    db.delete(db_book)
    db.commit()
    logging.info(f"Book ID {book_id} removed by user {current_user.id} at {datetime.now()}")
    return {"detail": "Book deleted"}