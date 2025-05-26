from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Subscription, Delivery
from ..dtos import SubscriptionCreate, DeliveryStatus
from ..utils import process_payment, fetch_top_selling_sci_fi_book

router = APIRouter(
    prefix="/subscriptions",
    tags=["subscriptions"]
)

@router.post("/", response_model=SubscriptionCreate, summary="Subscribe to SciFi Book Subscription")
def subscribe_to_scifi(
    subscription: SubscriptionCreate = Body(...),
    db: Session = Depends(get_db)
):
    payment_response = process_payment(subscription.payment_info)
    if payment_response.status != "success":
        raise HTTPException(status_code=400, detail="Payment failed")
    db_subscription = Subscription(
        user_id=subscription.user_id,
        delivery_details=subscription.delivery_details,
        payment_info=subscription.payment_info,
        status="active"
    )
    db.add(db_subscription)
    db.commit()
    db.refresh(db_subscription)
    return db_subscription

@router.post("/{subscription_id}/deliver", response_model=DeliveryStatus, summary="Receive Monthly SciFi Book")
def deliver_scifi_book(
    subscription_id: int = Path(...),
    db: Session = Depends(get_db)
):
    subscription = db.query(Subscription).filter(Subscription.id == subscription_id).first()
    if not subscription:
        raise HTTPException(status_code=404, detail="Subscription not found")
    book = fetch_top_selling_sci_fi_book()
    delivery_status = "delayed" if not book else "delivered"
    delivery = Delivery(
        subscription_id=subscription_id,
        book_id=book.book_id if book else None,
        delivery_status=delivery_status
    )
    db.add(delivery)
    db.commit()
    db.refresh(delivery)
    if delivery_status == "delayed":
        raise HTTPException(status_code=400, detail="Delivery delayed")
    return delivery
