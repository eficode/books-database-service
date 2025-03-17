from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter(
    prefix="/books",
    tags=["book details"]
)

@router.get("/{book_id}/details", response_model=BookInfo,
         summary="Get book details",
         description="This endpoint retrieves the details of a book",
         response_description="The book's details")
def get_book_details(
    book_id: int = Path(..., description="The ID of the book to be retrieved"),
    db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return BookInfo(**db_book.__dict__)
