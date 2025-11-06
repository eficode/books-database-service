from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from typing import List
from ..database import get_db
from ..models import Favourite, Book
from ..dtos import FavouriteCreate, FavouriteInfo, ReorderFavourite, ReorderFavouriteResponse

router = APIRouter(
    prefix="/favourites",
    tags=["favourites"]
)

@router.post("/", response_model=FavouriteInfo, status_code=201)
def add_favourite(favourite: FavouriteCreate, db: Session = Depends(get_db)):
    try:
        db_favourite = Favourite(user_id=1, book_id=favourite.book_id, position=0) # Assuming user_id is 1 for simplicity
        db.add(db_favourite)
        db.commit()
        db.refresh(db_favourite)
        book = db.query(Book).filter(Book.id == db_favourite.book_id).first()
        return FavouriteInfo(
            id=db_favourite.id,
            user_id=db_favourite.user_id,
            book_id=db_favourite.book_id,
            book_title=book.title,
            book_author=book.author
        )
    except SQLAlchemyError:
        raise HTTPException(status_code=500, detail="Network error. Please try again.")

@router.get("/", response_model=List[FavouriteInfo])
def get_favourites(db: Session = Depends(get_db)):
    favourites = db.query(Favourite).filter(Favourite.user_id == 1).all() # Assuming user_id is 1 for simplicity
    if not favourites:
        raise HTTPException(status_code=404, detail="No favourite books available.")
    result = []
    for fav in favourites:
        book = db.query(Book).filter(Book.id == fav.book_id).first()
        result.append(FavouriteInfo(
            id=fav.id,
            user_id=fav.user_id,
            book_id=fav.book_id,
            book_title=book.title,
            book_author=book.author
        ))
    return result

@router.delete("/{favourite_id}", status_code=204)
def remove_favourite(favourite_id: int, db: Session = Depends(get_db)):
    try:
        db_favourite = db.query(Favourite).filter(Favourite.id == favourite_id).first()
        if db_favourite is None:
            raise HTTPException(status_code=404, detail="Favourite not found.")
        db.delete(db_favourite)
        db.commit()
    except SQLAlchemyError:
        raise HTTPException(status_code=500, detail="Server error. Please try again.")

@router.put("/reorder", response_model=List[ReorderFavouriteResponse])
def reorder_favourites(reorder_list: List[ReorderFavourite], db: Session = Depends(get_db)):
    try:
        for item in reorder_list:
            db_favourite = db.query(Favourite).filter(Favourite.id == item.id).first()
            if db_favourite is None:
                raise HTTPException(status_code=404, detail="Favourite not found.")
            db_favourite.position = item.new_position
        db.commit()
        result = []
        for item in reorder_list:
            db_favourite = db.query(Favourite).filter(Favourite.id == item.id).first()
            result.append(ReorderFavouriteResponse(
                id=db_favourite.id,
                user_id=db_favourite.user_id,
                book_id=db_favourite.book_id,
                position=db_favourite.position
            ))
        return result
    except SQLAlchemyError:
        raise HTTPException(status_code=500, detail="Client-side error. Please try again.")
