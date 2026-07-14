from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Favorite, Book
from ..dtos import FavoriteCreate, FavoriteInfo
from ..dependencies import get_current_user

router = APIRouter(
    prefix="/favorites",
    tags=["favorites"]
)

@router.get("/", response_model=List[FavoriteInfo],
    summary="Get all favorite tagged books",
    description="This endpoint retrieves all favorite tagged books for the logged-in user",
    response_description="A list of all favorite tagged books")
def read_favorites(current_user: int = Depends(get_current_user), db: Session = Depends(get_db)):
    favorites = db.query(Favorite).filter(Favorite.user_id == current_user).all()
    if not favorites:
        return []
    favorite_books = []
    for favorite in favorites:
        book = db.query(Book).filter(Book.id == favorite.book_id).first()
        if book:
            favorite_books.append(FavoriteInfo(id=favorite.id, book_id=book.id, title=book.title, author=book.author, pages=book.pages))
    return favorite_books

@router.post("/", response_model=FavoriteInfo,
    summary="Add a new book to favorites",
    description="This endpoint adds a new book to the user's favorites",
    response_description="The added favorite book's information")
def add_favorite(favorite: FavoriteCreate, current_user: int = Depends(get_current_user), db: Session = Depends(get_db)):
    existing_favorite = db.query(Favorite).filter(Favorite.user_id == current_user, Favorite.book_id == favorite.book_id).first()
    if existing_favorite:
        raise HTTPException(status_code=400, detail="The book is already in your favorites")
    db_favorite = Favorite(user_id=current_user, book_id=favorite.book_id)
    db.add(db_favorite)
    db.commit()
    db.refresh(db_favorite)
    book = db.query(Book).filter(Book.id == favorite.book_id).first()
    return FavoriteInfo(id=db_favorite.id, book_id=book.id, title=book.title, author=book.author, pages=book.pages)

@router.delete("/{book_id}",
    summary="Remove a book from favorites",
    description="This endpoint removes a book from the user's favorites",
    response_description="Confirmation message")
def remove_favorite(book_id: int, current_user: int = Depends(get_current_user), db: Session = Depends(get_db)):
    favorite = db.query(Favorite).filter(Favorite.user_id == current_user, Favorite.book_id == book_id).first()
    if not favorite:
        raise HTTPException(status_code=400, detail="The book cannot be removed as it is not in your favorites")
    db.delete(favorite)
    db.commit()
    return {"detail": "Book removed from favorites"}