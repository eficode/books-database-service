from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Favourite, Book
from ..dtos import FavouriteCreate
from ..dependencies import get_current_user

router = APIRouter(
    prefix="/favourites",
    tags=["favourites"]
)

@router.post("/", response_model=FavouriteCreate, summary="Add a book to favourites", description="This endpoint adds a book to the user's favourites list.", response_description="The added favourite's information")
def add_to_favourites(favourite: FavouriteCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    db_book = db.query(Book).filter(Book.id == favourite.book_id).first()
    if not db_book or db_book.category.lower() != "red":
        raise HTTPException(status_code=400, detail="Only red books can be added to favourites.")
    try:
        db_favourite = Favourite(user_id=current_user, book_id=favourite.book_id)
        db.add(db_favourite)
        db.commit()
        db.refresh(db_favourite)
        return db_favourite
    except Exception as e:
        raise HTTPException(status_code=500, detail="An error occurred while adding the book to favourites.")

@router.get("/", response_model=List[FavouriteCreate], summary="Get favourites list", description="This endpoint retrieves the user's favourites list.", response_description="A list of the user's favourite books")
def get_favourites(db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    try:
        favourites = db.query(Favourite).filter(Favourite.user_id == current_user).all()
        return favourites
    except Exception as e:
        raise HTTPException(status_code=500, detail="An error occurred while retrieving the favourites list.")
