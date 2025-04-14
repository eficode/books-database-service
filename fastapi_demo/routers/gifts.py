from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from ..database import get_db
from ..models import Gift
from ..dtos import GiftCreate, GiftInfo
from ..email_service import send_email

router = APIRouter()

@router.post("/gifts/", response_model=GiftInfo)
def create_gift(gift: GiftCreate, db: Session = Depends(get_db)):
    if not gift.recipient_name or not gift.recipient_address:
        raise HTTPException(status_code=400, detail="Recipient name and address are required")
    estimated_delivery_date = datetime.now() + timedelta(days=7)
    db_gift = Gift(**gift.dict(), estimated_delivery_date=estimated_delivery_date)
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)
    send_email(
        to=gift.sender_email,
        subject="Your gift order confirmation",
        body=f"Your gift order for {gift.recipient_name} has been confirmed."
    )
    return GiftInfo(**db_gift.__dict__)

@router.get("/gifts/{gift_id}", response_model=GiftInfo)
def read_gift(gift_id: int, db: Session = Depends(get_db)):
    gift = db.query(Gift).filter(Gift.id == gift_id).first()
    if gift is None:
        raise HTTPException(status_code=404, detail="Gift not found")
    return GiftInfo(**gift.__dict__)
