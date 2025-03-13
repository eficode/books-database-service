from fastapi import APIRouter, Depends, HTTPException, Body, Path, Security, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo, BookFavorite
from pydantic import BaseModel

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

security = HTTPBasic()

@router.delete("/{book_id}", summary="Delete a single outdated test book",
               description="This endpoint deletes a single outdated test book with the provided ID",
               response_description="Confirmation message")
def delete_book(book_id: int, db: Session = Depends(get_db)):
    """
    Delete a single book by ID.
    """
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    db.delete(db_book)
    db.commit()
    return {"detail": "Book deleted"}


@router.delete("/bulk", summary="Bulk delete multiple outdated test books",
               description="This endpoint deletes multiple outdated test books with the provided IDs",
               response_description="Confirmation message")
def bulk_delete_books(book_ids: List[int] = Body(..., description="List of book IDs to delete"),
                      db: Session = Depends(get_db)):
    books_to_delete = db.query(Book).filter(Book.id.in_(book_ids)).all()
    if not books_to_delete:
        raise HTTPException(status_code=404, detail="No books found to delete")
    if len(books_to_delete) != len(book_ids):
        raise HTTPException(status_code=404, detail="One or more books not found")
    for book in books_to_delete:
        db.delete(book)
    db.commit()
    return {"detail": "Books deleted"}

@router.patch("/{book_id}/favorite", summary="Toggle book favorite status",
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
