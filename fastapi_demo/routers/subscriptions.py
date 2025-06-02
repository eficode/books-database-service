from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Subscription, Delivery
from ..dtos import SubscriptionOptIn, DeliverySchedule, ManageSubscription

router = APIRouter(
    prefix="/subscriptions",
    tags=["subscriptions"]
)

@router.post("/opt-in")
def opt_in(subscription: SubscriptionOptIn, db: Session = Depends(get_db)):
    existing_subscription = db.query(Subscription).filter(Subscription.user_id == subscription.user_id).first()
    if existing_subscription:
        return {"message": "Subscription confirmed"}
    new_subscription = Subscription(user_id=subscription.user_id)
    db.add(new_subscription)
    db.commit()
    return {"message": "Subscription confirmed"}

@router.post("/deliveries/schedule")
def schedule_delivery(delivery: DeliverySchedule, db: Session = Depends(get_db)):
    subscription = db.query(Subscription).filter(Subscription.user_id == delivery.user_id).first()
    if not subscription or subscription.status != "active":
        raise HTTPException(status_code=400, detail="You have not opted-in for monthly book delivery")
    # Assuming we have a method to check if the delivery date has arrived
    # This is a placeholder for actual logic
    if not delivery_date_has_arrived(delivery.user_id):
        return {"message": "Delivery scheduled"}
    return {"message": "Delivery scheduled"}

@router.put("/manage")
def manage_subscription(manage: ManageSubscription, db: Session = Depends(get_db)):
    subscription = db.query(Subscription).filter(Subscription.user_id == manage.user_id).first()
    if not subscription:
        raise HTTPException(status_code=400, detail="You have not chosen to manage your subscription")
    if manage.action not in ["pause", "resume", "cancel"]:
        raise HTTPException(status_code=400, detail="Invalid action")
    subscription.status = manage.action
    db.commit()
    return {"message": "Subscription updated"}

# Placeholder function for checking delivery date
# This should be replaced with actual logic
def delivery_date_has_arrived(user_id: int) -> bool:
    return False
