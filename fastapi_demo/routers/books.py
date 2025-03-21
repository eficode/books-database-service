from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo
from typing import List
import requests
import time

router = APIRouter()

VALID_CATEGORIES = ["Fiction", "Non-Fiction", "Science", "History"]

# Mock function to check if user is authenticated
# In real implementation, replace with actual authentication check

def is_authenticated():
    return True

@router.get("/top-selling-books/{category}", response_model=List[BookInfo])
def get_top_selling_books(category: str, db: Session = Depends(get_db)):
    if not is_authenticated():
        raise HTTPException(status_code=401, detail="Not authenticated. Please log in.")

    if category not in VALID_CATEGORIES:
        raise HTTPException(status_code=400, detail="Invalid category")

    try:
        start_time = time.time()
        # Simulate API call to get sales data
        response = requests.get(f"https://api.example.com/sales-data/{category}")
        if response.status_code != 200:
            raise HTTPException(status_code=503, detail="Service is unavailable")

        elapsed_time = time.time() - start_time
        if elapsed_time > 2:
            return {"message": "The request is taking longer than expected", "data": response.json()}

        books = db.query(Book).filter(Book.category == category).order_by(Book.sales_rank.desc()).all()
        if not books:
            raise HTTPException(status_code=404, detail="No top-selling books found for this category")

        return [BookInfo(**book.__dict__) for book in books]
    except requests.exceptions.RequestException:
        raise HTTPException(status_code=503, detail="Service is unavailable")
