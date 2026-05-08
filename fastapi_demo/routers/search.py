from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book

router = APIRouter(
    prefix="/search",
    tags=["search"]
)

@router.get("/", summary="Search for a book", description="Search for a book by title.", response_description="A list of books matching the search criteria")
def search_books(title: str = Query(..., description="The title of the book to search for"), db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.title.ilike(f"%{title}%")).all()
    if not books:
        raise HTTPException(status_code=404, detail="No results found")
    return books
