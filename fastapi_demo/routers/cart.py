from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Cart
from ..dtos import CartCreate, CartInfo
from ..dependencies import get_current_user

router = APIRouter()

@router.post("/cart/", response_model=CartInfo)
def add_to_cart(cart: CartCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Simulate system error
    raise HTTPException(status_code=500, detail="System error: Unable to add book to shopping cart")