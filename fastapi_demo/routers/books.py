from fastapi import APIRouter, Depends, HTTPException, Body, Path, File, UploadFile
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo, BookFavorite
import shutil
import os

router = APIRouter(
    prefix="/books",
    tags=["books"]
)

ALLOWED_IMAGE_FORMATS = {"image/jpeg", "image/png", "image/gif"}
MAX_IMAGE_SIZE = 5 * 1024 * 1024  # 5 MB

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
def upload_book_cover(book_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    if file.content_type not in ALLOWED_IMAGE_FORMATS:
        raise HTTPException(status_code=400, detail="Unsupported image format")
    file_location = f"covers/{book_id}_{file.filename}"
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    book.cover_image = file_location
    db.commit()
    return {"message": "Book cover uploaded successfully"}

@router.get("/{book_id}/cover")
def view_book_cover(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None or not book.cover_image:
        raise HTTPException(status_code=404, detail="Book cover not found")
    try:
        return FileResponse(book.cover_image)
    except Exception:
        raise HTTPException(status_code=503, detail="Image storage service is down")

@router.put("/{book_id}/cover")
def update_book_cover(book_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    if file.content_type not in ALLOWED_IMAGE_FORMATS:
        raise HTTPException(status_code=400, detail="Unsupported image format")
    if file.size > MAX_IMAGE_SIZE:
        raise HTTPException(status_code=400, detail="Image size exceeds the limit")
    if book.cover_image:
        os.remove(book.cover_image)  # Remove old cover image
    file_location = f"covers/{book_id}_{file.filename}"
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    book.cover_image = file_location
    db.commit()
    return {"message": "Book cover updated successfully"}

@router.delete("/{book_id}/cover")
def remove_book_cover(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None or not book.cover_image:
        raise HTTPException(status_code=404, detail="Book cover not found")
    try:
        os.remove(book.cover_image)
        book.cover_image = None
        db.commit()
        return {"message": "Book cover removed successfully"}
    except Exception:
        raise HTTPException(status_code=503, detail="Image storage service is down")
