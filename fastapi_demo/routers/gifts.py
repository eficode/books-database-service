from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Gift
from ..dtos import GiftCreate, GiftInfo

router = APIRouter()

@router.post("/gifts/mothers-day", response_model=GiftInfo, status_code=201)
def create_gift(gift: GiftCreate, db: Session = Depends(get_db)):
    db_gift = Gift(**gift.dict())
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)
    return GiftInfo(**db_gift.__dict__)

@router.get("/gifts/mothers-day/{order_id}", response_model=GiftInfo)
def read_gift(order_id: int, db: Session = Depends(get_db)):
    gift = db.query(Gift).filter(Gift.id == order_id).first()
    if gift is None:
        raise HTTPException(status_code=404, detail="Gift not found")
    return GiftInfo(**gift.__dict__)
