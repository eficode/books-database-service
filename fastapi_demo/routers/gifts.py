from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Gift
from ..dtos import GiftCreate, GiftInfo

router = APIRouter()

@router.post("/gifts/mothers-day", response_model=GiftInfo)
def send_mothers_day_gift(gift: GiftCreate, db: Session = Depends(get_db)):
    # Validate mother's address
    if not gift.mother_address:
        raise HTTPException(status_code=400, detail="Mother's shipping address is required")
    # Simulate address validation
    if gift.mother_address.zip_code == "00000":
        raise HTTPException(status_code=400, detail="Invalid shipping address")
    db_gift = Gift(
        book_id=gift.book_id,
        mother_address=gift.mother_address.dict(),
        personal_message=gift.personal_message,
        status="pending"
    )
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)
    # Integrate with shipping service (mocked)
    # Send confirmation email (mocked)
    return GiftInfo(
        id=db_gift.id,
        book_id=db_gift.book_id,
        mother_address=db_gift.mother_address,
        personal_message=db_gift.personal_message,
        status=db_gift.status,
        created_at=db_gift.created_at.isoformat(),
        updated_at=db_gift.updated_at.isoformat()
    )
