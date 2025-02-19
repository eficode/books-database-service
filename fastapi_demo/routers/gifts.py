from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Gift
from ..dtos import GiftCreate, GiftInfo

router = APIRouter()

@router.post("/gifts/", response_model=GiftInfo, status_code=201,
      summary="Create a new gift purchase",
      description="This endpoint creates a new gift purchase with the provided details and returns the gift information",
      response_description="The created gift's information")
def create_gift(
   gift: GiftCreate = Body(..., description="The details of the gift to be created"),
   db: Session = Depends(get_db)):
   db_gift = Gift(**gift.dict())
   db.add(db_gift)
   db.commit()
   db.refresh(db_gift)
   return GiftInfo(**db_gift.__dict__)

@router.get("/gifts/{gift_id}", response_model=GiftInfo,
      summary="Retrieve details of a specific gift purchase",
      description="This endpoint retrieves the details of a gift purchase with the provided ID",
      response_description="The requested gift's information")
def read_gift(
   gift_id: int = Path(..., description="The ID of the gift to be retrieved"),
   db: Session = Depends(get_db)):
   db_gift = db.query(Gift).filter(Gift.id == gift_id).first()
   if db_gift is None:
     raise HTTPException(status_code=404, detail="Gift not found")
   return GiftInfo(**db_gift.__dict__)