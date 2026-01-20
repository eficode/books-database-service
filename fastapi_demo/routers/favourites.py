from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Favourite, Book
from ..dtos import FavouriteCreate, FavouriteInfo
from ..dependencies import get_current_user

router = APIRouter(
    prefix="/favourites",
    tags=["favourites"]
)

@router.post("/", response_model=FavouriteInfo, summary="Add a book to favourites")
def add_favourite(
    favourite: FavouriteCreate = Body(...),
    db: Session = Depends(get_db),
    current_user: int = Depends(get_current_user)
):
    existing_favourite = db.query(Favourite).filter(Favourite.user_id == current_user, Favourite.book_id == favourite.book_id).first()
    if existing_favourite:
        raise HTTPException(status_code=400, detail="The book is already in your favourites list")
    new_favourite = Favourite(user_id=current_user, book_id=favourite.book_id)
    db.add(new_favourite)
    db.commit()
    db.refresh(new_favourite)
    return FavouriteInfo(**new_favourite.__dict__)

@router.get("/", response_model=List[FavouriteInfo], summary="Get favourite books")
def get_favourites(
    db: Session = Depends(get_db),
    current_user: int = Depends(get_current_user)
):
    favourites = db.query(Favourite).filter(Favourite.user_id == current_user).all()
    if not favourites:
        raise HTTPException(status_code=404, detail="No favourite books found")
    return [FavouriteInfo(**favourite.__dict__) for favourite in favourites]

@router.delete("/{favourite_id}", summary="Remove a book from favourites")
def remove_favourite(
    favourite_id: int = Path(...),
    db: Session = Depends(get_db),
    current_user: int = Depends(get_current_user)
):
    favourite = db.query(Favourite).filter(Favourite.id == favourite_id, Favourite.user_id == current_user).first()
    if not favourite:
        raise HTTPException(status_code=404, detail="The book is not in your favourites list")
    db.delete(favourite)
    db.commit()
    return {"message": "Book removed from favourites"}