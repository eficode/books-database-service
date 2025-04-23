from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Gift
from ..dtos import GiftCreate, GiftInfo

router = APIRouter(
    prefix="/gifts",
    tags=["gifts"]
)

@router.post("/", response_model=GiftInfo)
def create_gift(gift: GiftCreate, db: Session = Depends(get_db)):
    db_gift = Gift(
        book_id=gift.book_id,
        recipient_name=gift.recipient_name,
        recipient_address=gift.recipient_address,
        status="Pending"
    )
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)
    return db_gift

@router.get("/{gift_id}", response_model=GiftInfo)
def read_gift(gift_id: int, db: Session = Depends(get_db)):
    db_gift = db.query(Gift).filter(Gift.gift_id == gift_id).first()
    if db_gift is None:
        raise HTTPException(status_code=404, detail="Gift not found")
    return db_gift
