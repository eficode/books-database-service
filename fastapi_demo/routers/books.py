from fastapi import APIRouter, Depends, HTTPException, File, UploadFile
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo, BookImportResponse, BookImportErrorResponse
import json
from pydantic import ValidationError

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

@router.post("/books/import", response_model=BookImportResponse, responses={400: {"model": BookImportErrorResponse}})
def import_books(file: UploadFile = File(...), db: Session = Depends(get_db)):
    if file.content_type != 'application/json':
        raise HTTPException(status_code=400, detail="Invalid file type. Only JSON files are allowed.")
    try:
        content = json.load(file.file)
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format.")
    imported_count = 0
    validation_errors = []
    for book_data in content:
        try:
            book = BookCreate(**book_data)
            db_book = Book(**book.dict())
            db.add(db_book)
            imported_count += 1
        except ValidationError as e:
            validation_errors.append(str(e))
    if validation_errors:
        raise HTTPException(status_code=400, detail={"error": "Validation error", "details": validation_errors})
    db.commit()
    return {"message": "Books imported successfully", "imported_count": imported_count}
