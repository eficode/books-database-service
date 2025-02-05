from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/best_selling_books/", response_model=List[BookInfo])
def get_best_selling_books(category: Optional[str] = None, sort_by_date: Optional[bool] = False, db: Session = Depends(get_db)):
    query = db.query(Book)

    if category:
        query = query.filter(Book.category == category)
        if query.count() == 0:
            raise HTTPException(status_code=404, detail="No best-selling books found in the selected category")

    if sort_by_date:
        try:
            query = query.order_by(Book.date.desc())
        except Exception:
            raise HTTPException(status_code=400, detail="The date range is invalid")

    books = query.all()
    if not books:
        raise HTTPException(status_code=404, detail="No best-selling books found")

    return books
