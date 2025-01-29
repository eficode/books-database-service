from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/users/{user_id}/new-releases", response_model=List[BookInfo])
def get_new_releases(user_id: int, db: Session = Depends(get_db)):
    user_books = db.query(Book).filter(Book.user_id == user_id).all()
    if not user_books:
        raise HTTPException(status_code=404, detail="User not found")
    authors = {book.author for book in user_books}
    new_releases = db.query(Book).filter(Book.author.in_(authors), Book.release_date > datetime.now()).all()
    if not new_releases:
        raise HTTPException(status_code=204, detail="No new releases available")
    return [BookInfo(**book.__dict__) for book in new_releases]
