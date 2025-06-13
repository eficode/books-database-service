from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Gift
from ..dtos import GiftCreate, GiftInfo

router = APIRouter()

@router.post("/gifts/", response_model=GiftInfo, status_code=201)
def create_gift(gift: GiftCreate, db: Session = Depends(get_db)):
    db_gift = Gift(**gift.dict())
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)
    # Integrate with shipping service here
    return GiftInfo(**db_gift.__dict__)