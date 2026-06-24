from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book, Favorite
from ..dtos import BookInfo
from ..dependencies import get_current_user

router = APIRouter(
    prefix="/favorites",
    tags=["favorites"]
)

@router.get('/', response_model=List[BookInfo])
def get_favorites(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    favorites = db.query(Book).join(Favorite, Favorite.book_id == Book.id).filter(Favorite.user_id == current_user.id).all()
    return [BookInfo.from_orm(book) for book in favorites]

@router.post('/{book_id}', response_model=dict)
def add_to_favorites(book_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Check if the book already exists in favorites
    existing_favorite = db.query(Favorite).filter(Favorite.user_id == current_user.id, Favorite.book_id == book_id).first()
    if existing_favorite:
        raise HTTPException(status_code=400, detail="Book already in favorites")
    favorite = Favorite(user_id=current_user.id, book_id=book_id)
    db.add(favorite)
    db.commit()
    return {"detail": "Book added to favorites"}

@router.delete('/{book_id}', response_model=dict)
def remove_from_favorites(book_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    favorite = db.query(Favorite).filter(Favorite.user_id == current_user.id, Favorite.book_id == book_id).first()
    if favorite:
        db.delete(favorite)
        db.commit()
        return {"detail": "Book removed from favorites"}
    raise HTTPException(status_code=404, detail="Favorite not found")