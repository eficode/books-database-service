from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Gift
from fastapi_demo.dtos import GiftCreate, GiftInfo

router = APIRouter()

@router.post("/gifts/mothers-day", response_model=GiftInfo)
def create_mothers_day_gift(gift: GiftCreate, db: Session = Depends(get_db)):
    if not gift.recipient_postcode.startswith("UK"):
        raise HTTPException(status_code=400, detail="Recipient's address must be within the UK")
    if not all([gift.book_id, gift.recipient_name, gift.recipient_address, gift.recipient_city, gift.recipient_postcode]):
        raise HTTPException(status_code=400, detail="All recipient details must be provided")
    db_gift = Gift(**gift.dict())
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)
    return GiftInfo(**db_gift.__dict__)

@router.get("/gifts/mothers-day/{gift_id}", response_model=GiftInfo)
def read_mothers_day_gift(gift_id: int, db: Session = Depends(get_db)):
    gift = db.query(Gift).filter(Gift.gift_id == gift_id).first()
    if gift is None:
        raise HTTPException(status_code=404, detail="Gift not found")
    return GiftInfo(**gift.__dict__)
