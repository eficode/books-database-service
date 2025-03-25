from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import GiftOrder
from ..dtos import GiftOrderCreate, GiftOrderInfo

router = APIRouter()

@router.post("/gifts/", response_model=GiftOrderInfo)
def create_gift_order(gift_order: GiftOrderCreate, db: Session = Depends(get_db)):
    if not gift_order.recipient_name or not gift_order.recipient_address or not gift_order.recipient_contact:
        raise HTTPException(status_code=400, detail="Recipient's delivery details are required")
    db_gift_order = GiftOrder(**gift_order.dict())
    db.add(db_gift_order)
    db.commit()
    db.refresh(db_gift_order)
    return GiftOrderInfo.from_orm(db_gift_order)

@router.get("/gifts/{order_id}", response_model=GiftOrderInfo)
def read_gift_order(order_id: int, db: Session = Depends(get_db)):
    gift_order = db.query(GiftOrder).filter(GiftOrder.id == order_id).first()
    if gift_order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    return GiftOrderInfo.from_orm(gift_order)