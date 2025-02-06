from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import ShoppingCart, Book
from ..dtos import CartItem, CartResponse
from ..auth import get_current_user

router = APIRouter()

@router.post("/cart/add", response_model=CartResponse)
def add_to_cart(book_id: int, db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    if book.stock <= 0:
        raise HTTPException(status_code=400, detail="The book is out of stock")
    cart_item = ShoppingCart(user_id=current_user, book_id=book.id, price=book.price)
    db.add(cart_item)
    db.commit()
    db.refresh(cart_item)
    cart = db.query(ShoppingCart).filter(ShoppingCart.user_id == current_user).all()
    return CartResponse(cart=[CartItem(book_id=item.book_id, title=book.title, price=item.price) for item in cart])

@router.get("/cart", response_model=CartResponse)
def view_cart(db: Session = Depends(get_db), current_user: int = Depends(get_current_user)):
    cart = db.query(ShoppingCart).filter(ShoppingCart.user_id == current_user).all()
    if not cart:
        raise HTTPException(status_code=200, detail="Your shopping cart is empty")
    return CartResponse(cart=[CartItem(book_id=item.book_id, title=book.title, price=item.price) for item in cart])
