from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book, FavouriteBooks
from ..dtos import BookInfo

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.get("/{user_id}/favourites", response_model=List[BookInfo])
def get_favourite_books(user_id: int, db: Session = Depends(get_db)):
    favourite_books = db.query(Book).join(FavouriteBooks, Book.id == FavouriteBooks.book_id).filter(FavouriteBooks.user_id == user_id).all()
    return [BookInfo(**book.__dict__) for book in favourite_books]

@router.post("/{user_id}/favourites/{book_id}/purchase")
def purchase_favourite_book(user_id: int, book_id: int, db: Session = Depends(get_db)):
    # Logic to initiate purchase process
    purchase_url = initiate_purchase_process(user_id, book_id)
    return {"purchase_url": purchase_url}

# Mock function for initiating purchase process
# Replace this with actual logic
def initiate_purchase_process(user_id: int, book_id: int) -> str:
    return f"https://purchase.url/user/{user_id}/book/{book_id}"