from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Favorite, Book
from fastapi_demo.dtos import FavoriteCreate, FavoriteInfo, BookInfo
from fastapi_demo.auth import get_current_user
from typing import List

router = APIRouter()

@router.post("/favorites/", response_model=FavoriteInfo)
def add_to_favorites(favorite: FavoriteCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        db_favorite = Favorite(book_id=favorite.book_id, user_id=current_user.id)
        db.add(db_favorite)
        db.commit()
        db.refresh(db_favorite)
        return FavoriteInfo(**db_favorite.__dict__)
    except Exception as e:
        raise HTTPException(status_code=500, detail="Network error: Unable to add to favorites")

@router.get("/favorites/", response_model=List[FavoriteInfo])
def get_favorites(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        favorites = db.query(Favorite).filter(Favorite.user_id == current_user.id).all()
        favorite_books = []
        for favorite in favorites:
            book = db.query(Book).filter(Book.id == favorite.book_id).first()
            favorite_books.append(FavoriteInfo(id=favorite.id, book_id=favorite.book_id, user_id=favorite.user_id, book_details=BookInfo(**book.__dict__)))
        return favorite_books
    except Exception as e:
        raise HTTPException(status_code=500, detail="Server error: Unable to load favorites list")

@router.delete("/favorites/{favorite_id}")
def remove_from_favorites(favorite_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        favorite = db.query(Favorite).filter(Favorite.id == favorite_id, Favorite.user_id == current_user.id).first()
        if favorite is None:
            raise HTTPException(status_code=404, detail="Favorite not found")
        db.delete(favorite)
        db.commit()
        return {"detail": "Favorite removed"}
    except Exception as e:
        raise HTTPException(status_code=500, detail="Network error: Unable to remove from favorites")