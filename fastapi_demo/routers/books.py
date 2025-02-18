from fastapi import APIRouter, Depends, HTTPException, Body, Path, Security
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo
from fastapi.security import OAuth2PasswordBearer
import logging
from datetime import datetime

router = APIRouter()

# OAuth2 scheme for token validation
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Logger setup
logger = logging.getLogger(__name__)

# Function to get current user and check if they are a Test Manager
def get_current_user(token: str = Security(oauth2_scheme)):
    # Implement token validation and user retrieval
    # Ensure the user has the Test Manager role
    # This is a placeholder implementation
    class User:
        def __init__(self, is_test_manager):
            self.is_test_manager = is_test_manager
            self.id = 1  # Example user ID
    return User(is_test_manager=True)  # Example: always return a Test Manager

@router.post("/books/",
    response_model=BookInfo,
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

@router.delete("/books/{book_id}")
def delete_book(book_id: int, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    db.delete(db_book)
    db.commit()
    return {"message": "Book deleted successfully"}

@router.delete("/books/test")
def delete_all_test_books(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not current_user.is_test_manager:
        raise HTTPException(status_code=403, detail="Not authorized")
    try:
        books_to_delete = db.query(Book).filter(Book.title.like('%test%')).all()
        if not books_to_delete:
            return {"detail": "No test books found to remove"}
        db.query(Book).filter(Book.title.like('%test%')).delete(synchronize_session=False)
        db.commit()
        logger.info(f"Test books removed by user {current_user.id} at {datetime.now()}")
        return {"detail": "All test books removed successfully"}
    except Exception as e:
        db.rollback()
        logger.error(f"Error removing test books: {str(e)}")
        if "partial" in str(e).lower():
            raise HTTPException(status_code=500, detail="Partial removal error: An error occurred while removing some test books")
        raise HTTPException(status_code=500, detail="An error occurred while removing test books")
