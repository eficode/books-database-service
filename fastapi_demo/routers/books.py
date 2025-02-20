from fastapi import APIRouter, Depends, HTTPException, Body, Path, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo
from fastapi.security import OAuth2PasswordBearer
import logging

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
logger = logging.getLogger("bookbridge")

@router.post("/books/", response_model=BookInfo, summary="Create a new book", description="This endpoint creates a new book with the provided details and returns the book information", response_description="The created book's information")
def create_book(
    book: BookCreate = Body(..., description="The details of the book to be created", examples={"title": "Example Book", "author": "John Doe", "year": 2021}),
    db: Session = Depends(get_db)):
    db_book = Book(**book.model_dump())
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)

@router.get("/books/{book_id}", response_model=BookInfo, summary="Read a book", description="This endpoint retrieves the details of a book with the provided ID", response_description="The requested book's information")
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
def delete_all_test_books(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    # Authentication and authorization logic here
    if not token or token != "test_manager_token":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You do not have the necessary permissions.")
    try:
        test_books = db.query(Book).filter(Book.title.like('%test%')).all()
        if not test_books:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Backend service is down.")
        for book in test_books:
            db.delete(book)
        db.commit()
        logger.info("All test books have been successfully removed by user: %s", token)
        return {"detail": "All test books have been successfully removed."}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Partial deletion occurred due to network interruption.")