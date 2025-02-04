from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from ..database import get_db
from ..models import Book, Review
from ..dtos import BookCreate, BookInfo, ReviewCreate, ReviewInfo

router = APIRouter()

@router.get("/top-selling-books/", response_model=List[BookInfo], summary="Fetch top-selling books", description="This endpoint fetches a list of top-selling books, optionally filtered by category.", response_description="A list of top-selling books.")
def get_top_selling_books(category: Optional[str] = None, db: Session = Depends(get_db)):
    try:
        query = db.query(Book)
        if category:
            query = query.filter(Book.category == category)
        books = query.all()
        return [BookInfo(**book.__dict__) for book in books]
    except SQLAlchemyError:
        raise HTTPException(status_code=503, detail="Top-selling books cannot be retrieved at this time.")

@router.post("/books/{book_id}/review", response_model=ReviewInfo, summary="Submit a review and rating", description="This endpoint allows users to submit a review and rating for a book.", response_description="The submitted review and rating.")
def submit_review(book_id: int, review: ReviewCreate = Body(...), db: Session = Depends(get_db)):
    try:
        db_book = db.query(Book).filter(Book.id == book_id).first()
        if db_book is None:
            raise HTTPException(status_code=404, detail="Book not found")
        db_review = Review(**review.dict(), book_id=book_id)
        db.add(db_review)
        db.commit()
        db.refresh(db_review)
        return ReviewInfo(**db_review.__dict__)
    except SQLAlchemyError:
        raise HTTPException(status_code=503, detail="Your review and rating could not be saved.")