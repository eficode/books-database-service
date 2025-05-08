from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import PurchaseGift
from ..dtos import PurchaseGiftCreate, PurchaseGiftResponse, PurchaseGiftStatusResponse
from ..services import ShippingService, EmailService

router = APIRouter(
    prefix="/purchase-gift",
    tags=["purchase-gift"]
)

@router.post("/", response_model=PurchaseGiftResponse)
def purchase_gift(
    purchase_gift: PurchaseGiftCreate = Body(...),
    db: Session = Depends(get_db),
    shipping_service: ShippingService = Depends(),
    email_service: EmailService = Depends()
):
    try:
        tracking_number = shipping_service.ship_book(
            recipient_name=purchase_gift.recipient_name,
            recipient_address=purchase_gift.recipient_address,
            book_id=purchase_gift.book_id
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail="Invalid shipping details")

    new_purchase = PurchaseGift(
        book_id=purchase_gift.book_id,
        recipient_name=purchase_gift.recipient_name,
        recipient_address=purchase_gift.recipient_address,
        recipient_email=purchase_gift.recipient_email,
        status="shipped"
    )
    db.add(new_purchase)
    db.commit()
    db.refresh(new_purchase)

    try:
        email_service.send_confirmation(
            recipient_email=purchase_gift.recipient_email,
            purchase_details={
                "purchase_id": new_purchase.id,
                "status": new_purchase.status
            }
        )
    except Exception:
        pass

    return PurchaseGiftResponse(
        purchase_id=new_purchase.id,
        status=new_purchase.status,
        message="Purchase successful"
    )

@router.get("/{purchase_id}", response_model=PurchaseGiftStatusResponse)
def get_purchase_status(
    purchase_id: int = Path(...),
    db: Session = Depends(get_db)
):
    purchase = db.query(PurchaseGift).filter(PurchaseGift.id == purchase_id).first()
    if not purchase:
        raise HTTPException(status_code=404, detail="Purchase not found")
    return PurchaseGiftStatusResponse(
        purchase_id=purchase.id,
        status=purchase.status,
        book_id=purchase.book_id,
        recipient_name=purchase.recipient_name,
        recipient_address=purchase.recipient_address,
        recipient_email=purchase.recipient_email,
        purchase_date=purchase.purchase_date.isoformat(),
        delivery_date=purchase.delivery_date.isoformat() if purchase.delivery_date else None
    )