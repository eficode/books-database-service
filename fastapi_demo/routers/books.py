from fastapi import APIRouter, Depends, HTTPException, Body, Path, Query
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
from typing import List
from ..database import get_db
from ..models import Book, Sale
from ..dtos import BookCreate, BookInfo, BookFavorite
from datetime import datetime

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

@router.get("/low-selling-books/", response_model=List[BookInfo],
    summary="Get low-selling books",
    description="This endpoint retrieves low-selling books based on the specified date range and optional genre",
    response_description="A list of low-selling books")
def get_low_selling_books(
    start_date: str = Query(..., description="The start date for the sales period in YYYY-MM-DD format"),
    end_date: str = Query(..., description="The end date for the sales period in YYYY-MM-DD format"),
    genre: str = Query(None, description="Filter by book genre"),
    db: Session = Depends(get_db)):
    try:
        start_date = datetime.strptime(start_date, "%Y-%m-%d").date()
        end_date = datetime.strptime(end_date, "%Y-%m-%d").date()
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")

    sales_query = db.query(Sale.book_id, func.sum(Sale.quantity).label('total_sales'))
    sales_query = sales_query.filter(Sale.date >= start_date, Sale.date <= end_date)
    sales_query = sales_query.group_by(Sale.book_id)
    sales_query = sales_query.having(func.sum(Sale.quantity) == 0)

    if genre:
        sales_query = sales_query.join(Book, Sale.book_id == Book.id).filter(Book.category == genre)

    sales_data = sales_query.all()

    if not sales_data:
        raise HTTPException(status_code=404, detail="No sales data available for the specified period")

    book_ids = [sale.book_id for sale in sales_data]
    books = db.query(Book).filter(Book.id.in_(book_ids)).all()

    if not books:
        raise HTTPException(status_code=404, detail="No low-selling books to adjust orders for")

    return [BookInfo(**book.__dict__) for book in books]
