from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Cart, Favourite
from ..dtos import CartCreate
from ..dependencies import get_current_user

router = APIRouter(
    prefix="/cart",
    tags=["cart"]
)

@router.post("/", response_model=CartCreate, summary="Add a book to cart", description="This endpoint adds a book from the user's favourites list to the cart.", response_description="The added cart's information")
def add_to_cart(cart: CartCreate, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    db_favourite = db.query(Favourite).filter(Favourite.user_id == current_user, Favourite.book_id == cart.book_id).first()
    if not db_favourite:
        raise HTTPException(status_code=400, detail="The book is not in your favourites list.")
    try:
        db_cart = Cart(user_id=current_user, book_id=cart.book_id)
        db.add(db_cart)
        db.commit()
        db.refresh(db_cart)
        return db_cart
    except Exception as e:
        raise HTTPException(status_code=500, detail="An error occurred while adding the book to the cart.")
