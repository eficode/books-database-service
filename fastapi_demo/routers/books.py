from fastapi import APIRouter, Depends, HTTPException, Body, Path, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from datetime import date
from ..database import get_db
from ..models import Book, Sale
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

@router.get("/least-sold/", response_model=List[BookInfo],
    summary="Get least sold books",
    description="This endpoint retrieves the least sold books within an optional date range",
    response_description="A list of least sold books")
def get_least_sold_books(start_date: Optional[date] = Query(None), end_date: Optional[date] = Query(None), db: Session = Depends(get_db)):
    if start_date and end_date and start_date > end_date:
        raise HTTPException(status_code=400, detail="The date range is invalid")
    query = db.query(Book, func.sum(Sale.quantity).label('total_sales'))
    query = query.join(Sale, Book.id == Sale.book_id)
    if start_date:
        query = query.filter(Sale.date >= start_date)
    if end_date:
        query = query.filter(Sale.date <= end_date)
    query = query.group_by(Book.id)
    query = query.order_by('total_sales')
    books = query.all()
    if not books:
        raise HTTPException(status_code=404, detail="No results found")
    return [BookInfo(id=book.id, title=book.title, author=book.author, pages=book.pages, sales=total_sales) for book, total_sales in books]