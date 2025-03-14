from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo, BookFavorite

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
    db_book = Book(**book.model_dump(), added_date=datetime.utcnow().date())
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

@router.get("/week-old", response_model=List[BookInfo],
         summary="Get books that are a week old",
         description="This endpoint retrieves books that were added exactly a week ago",
         response_description="A list of books that are a week old")
def get_week_old_books(db: Session = Depends(get_db)):
    one_week_ago = datetime.utcnow().date() - timedelta(days=7)
    books = db.query(Book).filter(Book.added_date == one_week_ago).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books found that are a week old")
    return [BookInfo(**book.__dict__) for book in books]


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
