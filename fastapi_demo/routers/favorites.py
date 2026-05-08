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

@router.post("/", response_model=FavoriteInfo, summary="Add to Favorites", description="This endpoint adds a book to the user's favorites.", response_description="The favorite entry created")
def add_to_favorites(
    favorite: FavoriteCreate = Body(..., description="The details of the favorite to be created"),
    db: Session = Depends(get_db),
    current_user: int = Depends(get_current_user)
):
    db_favorite = Favorite(user_id=current_user, book_id=favorite.book_id)
    db.add(db_favorite)
    db.commit()
    db.refresh(db_favorite)
    return FavoriteInfo(**db_favorite.__dict__)

@router.get("/", response_model=List[FavoriteInfo], summary="Get Favorites", description="This endpoint retrieves the list of favorite books for the logged-in user.", response_description="A list of favorite books")
def get_favorites(db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    favorites = db.query(Favorite).filter(Favorite.user_id == current_user).all()
    return [FavoriteInfo(**favorite.__dict__) for favorite in favorites]

@router.delete("/{favorite_id}", summary="Remove from Favorites", description="This endpoint removes a book from the user's favorites.", response_description="Confirmation message")
def remove_from_favorites(favorite_id: int = Path(..., description="The ID of the favorite to be removed"), db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    db_favorite = db.query(Favorite).filter(Favorite.id == favorite_id, Favorite.user_id == current_user).first()
    if db_favorite is None:
        raise HTTPException(status_code=404, detail="Favorite not found")
    db.delete(db_favorite)
    db.commit()
    return {"detail": "Favorite removed"}
