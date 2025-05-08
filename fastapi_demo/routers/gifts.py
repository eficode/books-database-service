from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel, validator
from ..database import get_db
from ..models import GiftOrder
from datetime import datetime
import requests

router = APIRouter()

class GiftOrderCreate(BaseModel):
    gift_id: int
    recipient_name: str
    recipient_address: str

    @validator('recipient_address')
    def validate_address(cls, v):
        if not v or len(v) < 5:  # Simple validation for example purposes
            raise ValueError('Invalid delivery address')
        return v

class GiftOrderResponse(BaseModel):
    order_id: int
    status: str
    delivery_date: str = None

@router.post("/gifts/mothers-day", response_model=GiftOrderResponse)
async def create_gift_order(order: GiftOrderCreate, db: Session = Depends(get_db)):
    try:
        order.recipient_address = GiftOrderCreate.validate_address(order.recipient_address)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    gift_order = GiftOrder(
        gift_id=order.gift_id,
        recipient_name=order.recipient_name,
        recipient_address=order.recipient_address
    )
    db.add(gift_order)
    db.commit()
    db.refresh(gift_order)

    try:
        send_to_delivery_service(gift_order.id, gift_order.recipient_name, gift_order.recipient_address)
    except Exception as e:
        gift_order.status = 'failed'
        db.commit()
        notify_customer(gift_order.id)
        raise HTTPException(status_code=500, detail='Failed to send to delivery service')

    return GiftOrderResponse(order_id=gift_order.id, status=gift_order.status)

@router.get("/gifts/mothers-day/{order_id}", response_model=GiftOrderResponse)
async def get_gift_order(order_id: int, db: Session = Depends(get_db)):
    gift_order = db.query(GiftOrder).filter(GiftOrder.id == order_id).first()
    if gift_order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    return GiftOrderResponse(order_id=gift_order.id, status=gift_order.status, delivery_date=gift_order.delivery_date)


def send_to_delivery_service(order_id: int, recipient_name: str, recipient_address: str):
    response = requests.post("https://delivery-service.example.com/api/send", json={
        "order_id": order_id,
        "recipient_name": recipient_name,
        "recipient_address": recipient_address
    })
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception("Failed to send to delivery service")


def notify_customer(order_id: int):
    # Logic to notify the customer (e.g., via email or SMS)
    pass
