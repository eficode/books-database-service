from fastapi import APIRouter, Depends, HTTPException, Body, Path, Query
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo, BookFavorite
import csv
from fastapi.responses import StreamingResponse
from io import StringIO

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

@router.get("/top-sold", response_model=List[BookInfo],
    summary="Get top 3 most sold books",
    description="This endpoint retrieves the top 3 most sold books in a specific language",
    response_description="A list of top 3 most sold books")
def get_top_sold_books(language: str = Query(..., description="The language of the books to filter by"), db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.category == language).order_by(Book.sales.desc()).limit(3).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books available in the specified language")
    return [BookInfo(**book.__dict__) for book in books]

@router.post("/top-sold/export",
    summary="Export top 3 most sold books",
    description="This endpoint exports the top 3 most sold books data in a format suitable for the marketing team",
    response_description="A CSV file containing the top 3 most sold books data")
def export_top_sold_books(language: str = Body(..., description="The language of the books to filter by"), db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.category == language).order_by(Book.sales.desc()).limit(3).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books available in the specified language")
    output = StringIO()
    writer = csv.writer(output)
    writer.writerow(["id", "title", "author", "pages", "sales"])
    for book in books:
        writer.writerow([book.id, book.title, book.author, book.pages, book.sales])
    output.seek(0)
    response = StreamingResponse(output, media_type="application/octet-stream")
    response.headers["Content-Disposition"] = "attachment; filename=top_sold_books.csv"
    return response
