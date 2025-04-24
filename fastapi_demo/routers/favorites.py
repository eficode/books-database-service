from fastapi import APIRouter, Depends, HTTPException, status, Body, Path
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Favorite, Book
from ..dtos import FavoriteCreate, FavoriteInfo
from typing import List

router = APIRouter(
    prefix="/favorites",
    tags=["favorites"]
)

@router.post("/", response_model=FavoriteInfo, status_code=status.HTTP_201_CREATED,
    summary="Add a Book to Favorites",
    description="This endpoint adds a book to the user's favorites",
    response_description="The added favorite's information")
def add_favorite(favorite: FavoriteCreate, db: Session = Depends(get_db)):
    try:
        db_favorite = Favorite(**favorite.model_dump())
        db.add(db_favorite)
        db.commit()
        db.refresh(db_favorite)
        return FavoriteInfo(**db_favorite.__dict__)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Network issue, please try again later")

@router.get("/", response_model=List[FavoriteInfo],
    summary="View Favorites Page",
    description="This endpoint retrieves all books in the user's favorites",
    response_description="A list of all favorite books")
def view_favorites(db: Session = Depends(get_db)):
    try:
        favorites = db.query(Favorite).all()
        return [FavoriteInfo(**favorite.__dict__) for favorite in favorites]
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Server error, please try again later")

@router.delete("/{favorite_id}",
    summary="Remove a Book from Favorites",
    description="This endpoint removes a book from the user's favorites",
    response_description="Confirmation message")
def remove_favorite(favorite_id: int = Path(..., description="The ID of the favorite to be removed"), db: Session = Depends(get_db)):
    try:
        db_favorite = db.query(Favorite).filter(Favorite.id == favorite_id).first()
        if db_favorite is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Favorite not found")
        db.delete(db_favorite)
        db.commit()
        return {"detail": "Favorite removed"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Network issue, please try again later")
