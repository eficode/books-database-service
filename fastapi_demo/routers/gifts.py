from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.dtos import GiftCreate, GiftInfo
from fastapi_demo.models import Gift
from fastapi_demo.utils import process_payment, call_shipping_service, send_confirmation_email

router = APIRouter()

@router.post("/gifts/mothers-day", response_model=GiftInfo)
def send_mothers_day_gift(gift: GiftCreate, db: Session = Depends(get_db)):
    # Validate shipping details
    if not gift.mother_address or not gift.mother_city or not gift.mother_country:
        raise HTTPException(status_code=400, detail="Invalid shipping details")

    # Process payment
    payment_status = process_payment(gift.payment_details)
    if not payment_status['success']:
        raise HTTPException(status_code=400, detail="Payment failed")

    # Create gift order
    db_gift = Gift(
        gift_id=gift.gift_id,
        user_id=1, # Assuming a logged-in user with ID 1 for simplicity
        mother_name=gift.mother_name,
        mother_address=gift.mother_address,
        mother_city=gift.mother_city,
        mother_country=gift.mother_country,
        status="Processing"
    )
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)

    # Call shipping service API
    try:
        shipping_details = call_shipping_service(gift)
        db_gift.tracking_number = shipping_details['tracking_number']
        db_gift.estimated_delivery = shipping_details['estimated_delivery']
        db_gift.status = "Shipped"
        db.commit()
        # Send confirmation email
        send_confirmation_email("user@example.com", db_gift) # Assuming a logged-in user with email user@example.com
    except Exception as e:
        db_gift.status = "Processing Error"
        db.commit()
        raise HTTPException(status_code=500, detail="Gift processing failed")

    return GiftInfo(order_id=db_gift.id, status=db_gift.status, shipping_details=shipping_details)