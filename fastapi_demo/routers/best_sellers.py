from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from ..models import Book
from ..dtos import BookInfo
from ..database import get_db

router = APIRouter()

@router.get("/best-sellers/", response_model=List[BookInfo])
def get_best_sellers(db: Session = Depends(get_db)):
    best_sellers = db.query(Book).order_by(Book.sales.desc()).limit(10).all()
    return [BookInfo(**book.__dict__) for book in best_sellers]
