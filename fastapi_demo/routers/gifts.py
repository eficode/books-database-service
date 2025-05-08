from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Gift, Cart, RecipientAddress, Order
from ..dtos import GiftCreate, GiftInfo, CartCreate, CartInfo, RecipientAddressCreate, RecipientAddressInfo, OrderCreate, OrderInfo, EmailNotification

router = APIRouter(
    prefix="/mothers-day-gifts",
    tags=["mothers-day-gifts"]
)

@router.get("/", response_model=List[GiftInfo],
    summary="Get all Mother's Day gifts",
    description="This endpoint retrieves all Mother's Day gifts from the database",
    response_description="A list of all Mother's Day gifts")
def read_gifts(db: Session = Depends(get_db)):
    gifts = db.query(Gift).all()
    return [GiftInfo(**gift.__dict__) for gift in gifts]

@router.post("/cart/", response_model=CartInfo,
    summary="Add gift to cart",
    description="This endpoint adds a gift to the cart",
    response_description="The added gift's information")
def add_gift_to_cart(
    cart: CartCreate = Body(..., description="The details of the gift to be added to the cart"),
    db: Session = Depends(get_db)):
    db_gift = db.query(Gift).filter(Gift.id == cart.gift_id).first()
    if db_gift is None or db_gift.stock < cart.quantity:
        raise HTTPException(status_code=400, detail="The item is out of stock")
    db_cart = Cart(**cart.dict())
    db.add(db_cart)
    db.commit()
    db.refresh(db_cart)
    return CartInfo(**db_cart.__dict__)

@router.post("/checkout/recipient-address/", response_model=RecipientAddressInfo,
    summary="Enter recipient's address",
    description="This endpoint enters the recipient's address",
    response_description="The entered recipient's address information")
def enter_recipient_address(
    address: RecipientAddressCreate = Body(..., description="The details of the recipient's address"),
    db: Session = Depends(get_db)):
    if not address.recipient_address or len(address.recipient_address) < 5:
        raise HTTPException(status_code=400, detail="The address is invalid")
    db_address = RecipientAddress(**address.dict())
    db.add(db_address)
    db.commit()
    db.refresh(db_address)
    return RecipientAddressInfo(**db_address.__dict__)

@router.post("/checkout/confirm/", response_model=OrderInfo,
    summary="Confirm order",
    description="This endpoint confirms the order",
    response_description="The confirmed order's information")
def confirm_order(
    order: OrderCreate = Body(..., description="The details of the order to be confirmed"),
    db: Session = Depends(get_db)):
    db_address = db.query(RecipientAddress).filter(RecipientAddress.cart_id == order.cart_id).first()
    if db_address is None or not db_address.recipient_address or len(db_address.recipient_address) < 5:
        raise HTTPException(status_code=400, detail="The recipient's address is missing or incorrect")
    db_order = Order(**order.dict(), status="Confirmed")
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return OrderInfo(**db_order.__dict__)

@router.post("/notifications/send-confirmation/", response_model=dict,
    summary="Send order confirmation email",
    description="This endpoint sends the order confirmation email",
    response_description="The status of the email sending process")
def send_order_confirmation_email(
    email_notification: EmailNotification = Body(..., description="The details of the email notification"),
    db: Session = Depends(get_db)):
    # Simulate email sending process
    email_sent = True # This should be replaced with actual email sending logic
    if not email_sent:
        raise HTTPException(status_code=500, detail="Failed to send order confirmation email")
    return {"status": "Email sent successfully"}