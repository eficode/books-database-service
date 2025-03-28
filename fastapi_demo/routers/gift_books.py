from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import GiftOrder
from ..dtos import GiftOrderCreate, GiftOrderInfo
from ..payment import process_payment
from ..delivery import schedule_delivery

router = APIRouter()

@router.post('/gift-books/', response_model=GiftOrderInfo)
def create_gift_order(gift_order: GiftOrderCreate, db: Session = Depends(get_db)):
    # Check for missing delivery address
    if not gift_order.recipient_address:
        raise HTTPException(status_code=400, detail='Recipient address is required')
    # Process payment
    payment_status = process_payment(gift_order.payment_info)
    if not payment_status['success']:
        raise HTTPException(status_code=400, detail='Payment failed')
    # Create gift order
    db_gift_order = GiftOrder(
        book_id=gift_order.book_id,
        recipient_name=gift_order.recipient_name,
        recipient_address=gift_order.recipient_address,
        status='processing'
    )
    db.add(db_gift_order)
    db.commit()
    db.refresh(db_gift_order)
    # Schedule delivery
    delivery_status = schedule_delivery(db_gift_order.id, gift_order.recipient_address)
    if not delivery_status['success']:
        db_gift_order.status = 'delivery_failed'
    else:
        db_gift_order.status = 'completed'
    db.commit()
    db.refresh(db_gift_order)
    return GiftOrderInfo(**db_gift_order.__dict__)