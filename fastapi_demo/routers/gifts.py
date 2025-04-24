from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Gift
from ..dtos import GiftCreate, GiftInfo
import requests

router = APIRouter()

@router.post("/gifts/mothers-day", response_model=GiftInfo)
def create_mothers_day_gift(gift: GiftCreate, db: Session = Depends(get_db)):
    if not gift.recipient_name or not gift.recipient_address:
        raise HTTPException(status_code=400, detail="Recipient details are required")
    if not validate_address(gift.recipient_address):
        raise HTTPException(status_code=400, detail="Invalid address")
    db_gift = Gift(**gift.dict())
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)
    initiate_delivery(db_gift, db)
    return GiftInfo(**db_gift.__dict__)

def validate_address(address: str) -> bool:
    # Placeholder for address validation logic
    return True

def initiate_delivery(gift: Gift, db: Session):
    response = requests.post("https://delivery-service.example.com/api/send", json={
        "recipient_name": gift.recipient_name,
        "recipient_address": gift.recipient_address,
        "book_id": gift.book_id
    })
    if response.status_code == 200:
        gift.status = "shipped"
    else:
        gift.status = "failed"
    db.commit()
