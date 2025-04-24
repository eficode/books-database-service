from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import FavoriteAuthor
from fastapi_demo.dtos import FavoriteAuthorCreate, FavoriteAuthorResponse
from fastapi_demo.auth import get_current_user
from typing import List

router = APIRouter(prefix="/favorites/authors", tags=["favorites"])

@router.post("/", response_model=FavoriteAuthorResponse, status_code=status.HTTP_201_CREATED)
def add_author_to_favorites(favorite_author: FavoriteAuthorCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    existing_favorite = db.query(FavoriteAuthor).filter_by(user_id=current_user, author_id=favorite_author.author_id).first()
    if existing_favorite:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Author is already in favorites")
    new_favorite = FavoriteAuthor(user_id=current_user, author_id=favorite_author.author_id)
    db.add(new_favorite)
    db.commit()
    db.refresh(new_favorite)
    return new_favorite

@router.get("/", response_model=List[FavoriteAuthorResponse])
def view_favorites_list(db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    favorites = db.query(FavoriteAuthor).filter_by(user_id=current_user).all()
    if not favorites:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No favorite authors found")
    return favorites

@router.delete("/{author_id}", response_model=dict)
def remove_author_from_favorites(author_id: int, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    favorite = db.query(FavoriteAuthor).filter_by(user_id=current_user, author_id=author_id).first()
    if not favorite:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Author not found in favorites")
    db.delete(favorite)
    db.commit()
    return {"detail": "Author removed from favorites"}