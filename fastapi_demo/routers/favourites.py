from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Favourite, Book
from ..dtos import FavouriteCreate, FavouriteInfo
from ..auth import get_current_user

router = APIRouter(
    prefix="/favourites",
    tags=["favourites"]
)

@router.post("/", response_model=FavouriteInfo, summary="Add a book to favourites", description="This endpoint adds a book to the user's favourites list", response_description="The favourite's information")
def add_to_favourites(favourite: FavouriteCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    try:
        db_favourite = Favourite(user_id=current_user, book_id=favourite.book_id)
        db.add(db_favourite)
        db.commit()
        db.refresh(db_favourite)
        return FavouriteInfo(**db_favourite.__dict__)
    except Exception as e:
        raise HTTPException(status_code=500, detail="An error occurred while adding the book to favourites")

@router.get("/", response_model=List[FavouriteInfo], summary="View favourites", description="This endpoint retrieves the user's favourite books", response_description="A list of favourite books")
def view_favourites(db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    try:
        favourites = db.query(Favourite).filter(Favourite.user_id == current_user).all()
        return [FavouriteInfo(**favourite.__dict__) for favourite in favourites]
    except Exception as e:
        raise HTTPException(status_code=500, detail="An error occurred while retrieving the favourites")

@router.delete("/{favourite_id}", summary="Remove a book from favourites", description="This endpoint removes a book from the user's favourites list", response_description="Confirmation message")
def remove_from_favourites(favourite_id: int, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    try:
        db_favourite = db.query(Favourite).filter(Favourite.id == favourite_id, Favourite.user_id == current_user).first()
        if db_favourite is None:
            raise HTTPException(status_code=404, detail="Favourite not found")
        db.delete(db_favourite)
        db.commit()
        return {"detail": "Favourite removed"}
    except Exception as e:
        raise HTTPException(status_code=500, detail="An error occurred while removing the book from favourites")