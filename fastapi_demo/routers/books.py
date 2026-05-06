from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book

router = APIRouter()

@router.get("/books/pricing")
def get_book_pricing(db: Session = Depends(get_db)):
    try:
        books = db.query(Book).all()
        if not books:
            return {"message": "No pricing information available"}
        return {"books": [{"id": book.id, "title": book.title, "price": book.price} for book in books]}
    except Exception as e:
        if "No internet connection" in str(e):
            raise HTTPException(status_code=500, detail="The webpage cannot be loaded")
        elif "Server is down" in str(e):
            raise HTTPException(status_code=500, detail="The server is unavailable")
        else:
            raise HTTPException(status_code=500, detail="An unexpected error occurred")
