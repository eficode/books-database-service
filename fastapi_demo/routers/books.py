from fastapi import APIRouter, Depends, HTTPException, Body, Path, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo
from ..auth import get_current_user, User
import logging

router = APIRouter()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@router.post("/books/", response_model=BookInfo,
    summary="Create a new book",
    description="This endpoint creates a new book with the provided details and returns the book information",
    response_description="The created book's information")
def create_book(
    book: BookCreate = Body(..., description="The details of the book to be created", examples={"title": "Example Book", "author": "John Doe", "year": 2021}),
    db: Session = Depends(get_db)):
    db_book = Book(**book.model_dump())
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)

@router.get("/books/{book_id}",
    response_model=BookInfo,
    summary="Read a book",
    description="This endpoint retrieves the details of a book with the provided ID",
    response_description="The requested book's information")
def read_book(
    book_id: int = Path(..., description="The ID of the book to be retrieved", examples=1),
    db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return BookInfo(**db_book.__dict__)

@router.put("/books/{book_id}", response_model=BookInfo)
def update_book(book_id: int, book: BookCreate, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    for key, value in book.model_dump().items():
        setattr(db_book, key, value)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)

@router.delete("/books/{book_id}", status_code=status.HTTP_200_OK)
def delete_book(book_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Book not found")
    db.delete(db_book)
    db.commit()
    # Log the deletion action
    logger.info(f"User {current_user.id} deleted book {book_id} at {datetime.now()}")
    return {"detail": "Book deleted"}