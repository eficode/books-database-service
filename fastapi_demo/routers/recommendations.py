from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.post("/recommendations/occasion", response_model=List[BookInfo])
def get_recommendations(occasion: str, db: Session = Depends(get_db)):
    recommendations = db.query(Book).filter(Book.category == occasion).all()
    if not recommendations:
        if occasion == "Valentine's Day":
            raise HTTPException(status_code=404, detail="No recommendations available for Valentine's Day")
        elif occasion == "Mother's Day":
            raise HTTPException(status_code=404, detail="No recommendations available for Mother's Day")
        elif occasion == "Best Colleague Day":
            raise HTTPException(status_code=404, detail="No recommendations available for Best Colleague Day")
        else:
            raise HTTPException(status_code=404, detail="No recommendations found")
    return [BookInfo(**book.__dict__) for book in recommendations]
