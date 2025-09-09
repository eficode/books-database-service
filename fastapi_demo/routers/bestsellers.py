from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Bestseller, Cart, Order
from ..dtos import BestsellerInfo, CartAddRequest, CheckoutRequest, CheckoutResponse, BestsellersResponse

router = APIRouter(
    prefix="/bestsellers",
    tags=["bestsellers"]
)

@router.get("/{year}", response_model=BestsellersResponse)
def get_bestsellers(year: int, db: Session = Depends(get_db)):
    bestsellers = db.query(Bestseller).filter(Bestseller.year == year).all()
    if not bestsellers:
        raise HTTPException(status_code=404, detail="No bestsellers available for the selected year")
    return BestsellersResponse(bestsellers=[BestsellerInfo.from_orm(b) for b in bestsellers])

@router.post("/cart/add", response_model=dict)
def add_to_cart(request: CartAddRequest, db: Session = Depends(get_db)):
    bestseller = db.query(Bestseller).filter(Bestseller.id == request.book_id).first()
    if not bestseller:
        raise HTTPException(status_code=404, detail="Bestseller not found")
    if bestseller.stock <= 0:
        raise HTTPException(status_code=400, detail="The bestseller is out of stock")
    cart_item = Cart(user_id=1, book_id=request.book_id) # Assuming user_id is 1 for simplicity
    db.add(cart_item)
    db.commit()
    return {"message": "Bestseller added to cart successfully"}

@router.post("/checkout", response_model=CheckoutResponse)
def checkout(request: CheckoutRequest, db: Session = Depends(get_db)):
    cart_items = db.query(Cart).filter(Cart.user_id == 1).all() # Assuming user_id is 1 for simplicity
    if not cart_items:
        raise HTTPException(status_code=400, detail="No items in cart")
    total_amount = sum(item.bestseller.price for item in cart_items)
    # Simulate payment processing
    payment_success = False # Simulating payment failure
    if not payment_success:
        raise HTTPException(status_code=400, detail="Payment failed")
    order = Order(user_id=1, total_amount=total_amount, status="completed")
    db.add(order)
    db.commit()
    return CheckoutResponse(message="Purchase completed successfully", order_id=order.id)