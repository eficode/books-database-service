from fastapi import APIRouter, Depends, HTTPException, Body, Path, File, UploadFile
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo, BookFavorite
from ..utils import save_file_to_storage, validate_file_format, validate_file_size, simulate_network_failure, simulate_server_error

router = APIRouter(
    prefix="/books",
    tags=["books"]
)

@router.get("/", response_model=List[BookInfo],
    summary="Get all books",
    description="This endpoint retrieves all books from the database",
    response_description="A list of all books")
def read_books(db: Session = Depends(get_db)):
    books = db.query(Book).all()
    return [BookInfo(**book.__dict__) for book in books]

@router.post("/", response_model=BookInfo,
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

@router.get("/{book_id}",
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

@router.put("/{book_id}", response_model=BookInfo,
    summary="Update a book",
    description="This endpoint updates the details of a book with the provided ID",
    response_description="The updated book's information")
def update_book(book_id: int, book: BookCreate, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    for key, value in book.model_dump().items():
        setattr(db_book, key, value)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)

@router.delete("/{book_id}",
    summary="Delete a book",
    description="This endpoint deletes a book with the provided ID",
    response_description="Confirmation message")
def delete_book(book_id: int, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    db.delete(db_book)
    db.commit()
    return {"message": "Book deleted successfully"}

@router.patch("/{book_id}/favorite", response_model=BookInfo,
    summary="Toggle book favorite status",
    description="This endpoint toggles the favorite status of a book with the provided ID",
    response_description="The updated book's information")
def toggle_favorite(book_id: int, favorite: BookFavorite, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    db_book.favorite = favorite.favorite
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)

@router.post("/{book_id}/cover")
def upload_cover(book_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    # Validate file format
    if not validate_file_format(file.filename):
        raise HTTPException(status_code=400, detail="Unsupported file format")
    # Validate file size
    if not validate_file_size(file):
        raise HTTPException(status_code=400, detail="The file size is too large")
    # Simulate network failure
    if simulate_network_failure():
        raise HTTPException(status_code=503, detail="Upload failed due to network issues")
    # Simulate server error
    if simulate_server_error():
        raise HTTPException(status_code=500, detail="Upload failed due to server issues")
    # Save the file to the storage solution and get the URL
    cover_url = save_file_to_storage(file)
    book.cover_url = cover_url
    db.commit()
    return {"message": "Cover picture uploaded successfully", "cover_url": cover_url}

@router.get("/{book_id}/cover")
def get_cover(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None or book.cover_url is None:
        raise HTTPException(status_code=404, detail="Cover picture not found")
    return RedirectResponse(book.cover_url)
