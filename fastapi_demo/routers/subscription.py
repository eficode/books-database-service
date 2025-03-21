from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Subscription
from ..dtos import SubscriptionCreate, SubscriptionInfo
from ..email_service import send_confirmation_email

router = APIRouter(
    prefix="/subscription",
    tags=["subscription"]
)

@router.post("/subscribe", response_model=SubscriptionInfo, summary="Subscribe to Weekly Email", description="This endpoint subscribes a user to the weekly email list.", response_description="The subscription information")
def subscribe(subscription: SubscriptionCreate = Body(...), db: Session = Depends(get_db)):
    db_subscription = db.query(Subscription).filter(Subscription.email == subscription.email).first()
    if db_subscription:
        raise HTTPException(status_code=400, detail="Email already registered")
    new_subscription = Subscription(email=subscription.email)
    db.add(new_subscription)
    db.commit()
    db.refresh(new_subscription)
    try:
        send_confirmation_email(subscription.email)
    except Exception:
        db.delete(new_subscription)
        db.commit()
        raise HTTPException(status_code=500, detail="Confirmation email not sent")
    return SubscriptionInfo(**new_subscription.__dict__)

@router.post("/unsubscribe", response_model=dict, summary="Unsubscribe from Weekly Email", description="This endpoint unsubscribes a user from the weekly email list.", response_description="Confirmation message")
def unsubscribe(subscription: SubscriptionCreate = Body(...), db: Session = Depends(get_db)):
    db_subscription = db.query(Subscription).filter(Subscription.email == subscription.email).first()
    if not db_subscription:
        raise HTTPException(status_code=404, detail="Email not found")
    db.delete(db_subscription)
    db.commit()
    return {"message": "Unsubscription confirmed"}