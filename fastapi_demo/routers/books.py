from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo

router = APIRouter()

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

@router.delete("/books/{book_id}")
def delete_book(book_id: int, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    db.delete(db_book)
    db.commit()
    return {"message": "Book deleted successfully"}

@router.get("/books/{book_id}/availability", response_model=BookInfo)
def read_book_availability(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    predicted_delivery_time = calculate_predicted_delivery_time(book.stock_level)
    return {"id": book.id, "title": book.title, "author": book.author, "pages": book.pages, "stock_level": book.stock_level, "predicted_delivery_time": predicted_delivery_time}

@router.put("/books/{book_id}/availability", response_model=BookInfo)
def update_book_availability(book_id: int, stock_level: int, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    db_book.stock_level = stock_level
    db.commit()
    db.refresh(db_book)
    predicted_delivery_time = calculate_predicted_delivery_time(db_book.stock_level)
    return {"id": db_book.id, "title": db_book.title, "author": db_book.author, "pages": db_book.pages, "stock_level": db_book.stock_level, "predicted_delivery_time": predicted_delivery_time}


def calculate_predicted_delivery_time(stock_level: int) -> str:
    if stock_level > 10:
        return "1-2 days"
    elif stock_level > 0:
        return "3-5 days"
    else:
        return "Out of stock"
