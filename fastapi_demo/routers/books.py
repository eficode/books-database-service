from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book, Rating
from ..dtos import BookCreate, BookInfo, BookFavorite
from fastapi.security import OAuth2PasswordBearer

router = APIRouter(
    prefix="/books",
    tags=["books"]
)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

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

@router.post("/{book_id}/rate")
def rate_book(book_id: int, rating: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    if rating < 0 or rating > 5:
        raise HTTPException(status_code=400, detail="Rating must be between 0 and 5")
    try:
        user_id = get_user_id_from_token(token) # Implement this function to extract user ID from token
        db_rating = Rating(book_id=book_id, user_id=user_id, rating=rating)
        db.add(db_rating)
        db.commit()
        return {"message": "Rating submitted successfully"}
    except Exception as e:
        raise HTTPException(status_code=503, detail="The rating system is currently unavailable")

@router.get("/{book_id}/rating")
def get_average_rating(book_id: int, db: Session = Depends(get_db)):
    try:
        ratings = db.query(Rating).filter(Rating.book_id == book_id).all()
        if not ratings:
            return {"average_rating": 0}
        average_rating = sum(rating.rating for rating in ratings) / len(ratings)
        return {"average_rating": average_rating}
    except Exception as e:
        raise HTTPException(status_code=500, detail="The average rating cannot be displayed")
