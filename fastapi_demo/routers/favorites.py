from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book, FavoriteBook
from ..dtos import FavoriteBookCreate, FavoriteBooksResponse, FavoriteBookInfo

router = APIRouter(
    prefix="/users/{user_id}/favorites",
    tags=["favorites"]
)

@router.get("/", response_model=FavoriteBooksResponse,
    summary="Get all favorite books for a user",
    description="This endpoint retrieves all favorite books for a specific user",
    response_description="A list of all favorite books")
def get_favorite_books(user_id: int, db: Session = Depends(get_db)):
    favorite_books = db.query(FavoriteBook).filter(FavoriteBook.user_id == user_id).all()
    if not favorite_books:
        raise HTTPException(status_code=404, detail="There are no favorite books in your list")
    books = db.query(Book).filter(Book.id.in_([fav.book_id for fav in favorite_books])).all()
    return FavoriteBooksResponse(favorites=[FavoriteBookInfo(**book.__dict__) for book in books])

@router.post("/", response_model=FavoriteBookInfo,
    summary="Add a book to favorites",
    description="This endpoint adds a book to the user's favorite list",
    response_description="The added favorite book's information")
def add_favorite_book(user_id: int, favorite_book: FavoriteBookCreate, db: Session = Depends(get_db)):
    existing_favorite = db.query(FavoriteBook).filter(FavoriteBook.user_id == user_id, FavoriteBook.book_id == favorite_book.book_id).first()
    if existing_favorite:
        raise HTTPException(status_code=400, detail="The book is already in your favorites")
    db_favorite_book = FavoriteBook(user_id=user_id, book_id=favorite_book.book_id)
    db.add(db_favorite_book)
    db.commit()
    db.refresh(db_favorite_book)
    book = db.query(Book).filter(Book.id == favorite_book.book_id).first()
    return FavoriteBookInfo(**book.__dict__)

@router.delete("/{book_id}",
    summary="Remove a book from favorites",
    description="This endpoint removes a book from the user's favorite list",
    response_description="Confirmation message")
def remove_favorite_book(user_id: int, book_id: int, db: Session = Depends(get_db)):
    favorite_book = db.query(FavoriteBook).filter(FavoriteBook.user_id == user_id, FavoriteBook.book_id == book_id).first()
    if not favorite_book:
        raise HTTPException(status_code=404, detail="The book is not in your favorites")
    db.delete(favorite_book)
    db.commit()
    return {"message": "Book removed from favorites successfully"}