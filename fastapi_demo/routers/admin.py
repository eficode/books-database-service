from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..auth import get_current_admin_user
import logging

router = APIRouter()

@router.post("/admin/remove-test-books/", response_model=dict)
def remove_test_books(db: Session = Depends(get_db), current_user: dict = Depends(get_current_admin_user)):
    if not current_user['is_admin']:
        raise HTTPException(status_code=403, detail="Not authorized")
    try:
        test_books = db.query(Book).filter(Book.title.like('%test%')).all()
        for book in test_books:
            db.delete(book)
        db.commit()
        return {"detail": "All test books have been removed."}
    except Exception as e:
        db.rollback()
        logging.error(f"Error removing test books: {e}")
        raise HTTPException(status_code=500, detail="Database connection lost. Test books were not removed.")

@router.get("/admin/verify-no-test-books/", response_model=dict)
def verify_no_test_books(db: Session = Depends(get_db), current_user: dict = Depends(get_current_admin_user)):
    if not current_user['is_admin']:
        raise HTTPException(status_code=403, detail="Not authorized")
    try:
        test_books = db.query(Book).filter(Book.title.like('%test%')).all()
        if not test_books:
            return {"detail": "No test books found."}
        else:
            return {"detail": "Test books still exist in the database."}
    except Exception as e:
        logging.error(f"Error verifying test books: {e}")
        raise HTTPException(status_code=500, detail="Query failed due to a timeout.")