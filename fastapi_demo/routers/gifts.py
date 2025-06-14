from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Gift
from ..dtos import GiftCreate, GiftInfo
from ..email_service import send_email

router = APIRouter()

@router.post("/gifts/", response_model=GiftInfo)
def create_gift(gift: GiftCreate, db: Session = Depends(get_db), background_tasks: BackgroundTasks):
    db_gift = Gift(**gift.dict())
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)
    background_tasks.add_task(send_email, db_gift)
    return GiftInfo(**db_gift.__dict__)
