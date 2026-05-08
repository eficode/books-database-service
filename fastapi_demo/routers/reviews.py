from fastapi import APIRouter, HTTPException, Body, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book

router = APIRouter(
    prefix="/reviews",
    tags=["reviews"]
)

@router.post("/add", summary="Add a book review", description="Add a review to a book.", response_description="The review added")
def add_review(book_id: int = Body(..., description="The ID of the book to review"), review: str = Body(..., description="The review text"), db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    if book.favorite:
        raise HTTPException(status_code=400, detail="Review text area is disabled")
    # Assuming there is a reviews attribute in the Book model
    book.reviews.append(review)
    db.commit()
    return {"detail": "Review added"}
