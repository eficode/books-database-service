from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Order
from ..dtos import OrderCreate, OrderInfo

router = APIRouter()

@router.post("/orders/", response_model=OrderInfo)
def create_order(order: OrderCreate, db: Session = Depends(get_db)):
    # Validate recipient name and address
    if not order.recipient_name.strip():
        raise HTTPException(status_code=400, detail="Recipient name is required")
    if not validate_address(order.recipient_address):
        raise HTTPException(status_code=400, detail="Invalid address")

    db_order = Order(**order.dict())
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return OrderInfo(**db_order.__dict__)


def validate_address(address: str) -> bool:
    # Placeholder for actual validation logic
    return address.strip() != ""
