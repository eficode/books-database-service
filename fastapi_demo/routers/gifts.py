from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import GiftOrder
from fastapi_demo.dtos import GiftOrderCreate, GiftOrderInfo, GiftOrderStatus

router = APIRouter()

@router.post("/gifts/mothers-day", response_model=GiftOrderInfo)
def create_gift_order(order: GiftOrderCreate, db: Session = Depends(get_db)):
    if not validate_address(order.recipient_address):
        raise HTTPException(status_code=400, detail="Invalid address provided")
    db_order = GiftOrder(**order.dict())
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return GiftOrderInfo(**db_order.__dict__)

@router.get("/gifts/mothers-day/{order_id}/status", response_model=GiftOrderStatus)
def get_gift_order_status(order_id: int, db: Session = Depends(get_db)):
    order = db.query(GiftOrder).filter(GiftOrder.id == order_id).first()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    return GiftOrderStatus(**order.__dict__)

# Mock function to validate address
# In a real scenario, this should be replaced with actual address validation logic
def validate_address(address: str) -> bool:
    return address != "invalid"
