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

@router.post("/", response_model=FavoriteInfo, status_code=201,
    summary="Add a Book to Favorites",
    description="This endpoint adds a book to the user's favorite list",
    response_description="The added favorite book's information")
def add_favorite(
    favorite: FavoriteCreate = Body(..., description="The details of the favorite to be added"),
    db: Session = Depends(get_db),
    current_user: int = Depends(get_current_user)):
    db_favorite = db.query(Favorite).filter(Favorite.user_id == current_user, Favorite.book_id == favorite.book_id).first()
    if db_favorite:
        raise HTTPException(status_code=400, detail="The book is already in your favorites")
    db_favorite = Favorite(user_id=current_user, book_id=favorite.book_id)
    db.add(db_favorite)
    db.commit()
    db.refresh(db_favorite)
    return FavoriteInfo(**db_favorite.__dict__)

@router.delete("/{favorite_id}",
    summary="Remove a Book from Favorites",
    description="This endpoint removes a book from the user's favorite list",
    response_description="Confirmation message")
def remove_favorite(
    favorite_id: int = Path(..., description="The ID of the favorite to be removed"),
    db: Session = Depends(get_db),
    current_user: int = Depends(get_current_user)):
    db_favorite = db.query(Favorite).filter(Favorite.id == favorite_id, Favorite.user_id == current_user).first()
    if not db_favorite:
        raise HTTPException(status_code=400, detail="The book is not in your favorites")
    db.delete(db_favorite)
    db.commit()
    return {"detail": "Favorite book removed"}

@router.get("/", response_model=List[FavoriteInfo],
    summary="List Favorite Books",
    description="This endpoint retrieves all favorite books of the user",
    response_description="A list of all favorite books")
def list_favorites(
    db: Session = Depends(get_db),
    current_user: int = Depends(get_current_user)):
    favorites = db.query(Favorite).filter(Favorite.user_id == current_user).all()
    if not favorites:
        raise HTTPException(status_code=404, detail="You have no favorite books")
    return [FavoriteInfo(**favorite.__dict__) for favorite in favorites]
