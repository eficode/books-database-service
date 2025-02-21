from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book

router = APIRouter()

@router.get("/books/best-sellers/")
def get_best_selling_books(language: str = Query(...), db: Session = Depends(get_db)):
    try:
        books = db.query(Book).filter(Book.language == language).all()
        if not books:
            raise HTTPException(status_code=404, detail="No best-selling books available in the selected language")
        return {"books": books}
    except Exception:
        raise HTTPException(status_code=500, detail="There was an issue retrieving the best-selling books")
