from fastapi import APIRouter, Depends, HTTPException, Body, Request
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta, timezone
from ..database import get_db
from ..models import Gift, Book, GiftDataAccess
from ..dtos import GiftCreate, GiftInfo, GiftDataRequest, ConsentUpdate, DataRetentionInfo

router = APIRouter(
    prefix="/gifts",
    tags=["gifts"]
)

def log_data_access(db: Session, gift_id: int, access_type: str, request: Request, purpose: str = "gift_management"):
    """Log data access for GDPR compliance"""
    log_entry = GiftDataAccess(
        gift_id=gift_id,
        access_type=access_type,
        accessed_by="system",  # In real app, this would be the authenticated user
        access_purpose=purpose,
        ip_address=request.client.host if request.client else "unknown",
        user_agent=request.headers.get("user-agent", "unknown")
    )
    db.add(log_entry)
    db.commit()


@router.post("/", response_model=GiftInfo,
            summary="Create a new gift order",
            description="This endpoint creates a new gift order with GDPR compliance",
            response_description="The created gift order information")
def create_gift(
    request: Request,
    gift: GiftCreate = Body(..., description="The gift order details"),
    db: Session = Depends(get_db)
):
    # Verify consent is given
    if not gift.consent_given:
        raise HTTPException(status_code=400, detail="Explicit consent is required to process recipient data")
    
    # Verify book exists
    book = db.query(Book).filter(Book.id == gift.book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    
    # Create gift order with GDPR compliance
    db_gift = Gift(
        book_id=gift.book_id,
        consent_given=gift.consent_given,
        consent_timestamp=datetime.now(timezone.utc),
        purpose="gift_delivery",
        data_retention_until=datetime.now(timezone.utc) + timedelta(days=90),  # 90 days retention
        status="pending"
    )
    
    # Set encrypted recipient data
    db_gift.set_recipient_data(gift.recipient_name, gift.recipient_address, gift.recipient_country)
    
    db.add(db_gift)
    db.commit()
    db.refresh(db_gift)
    
    # Log the data creation
    log_data_access(db, db_gift.id, "CREATE", request, "gift_order_creation")
    
    return GiftInfo(
        id=db_gift.id,
        book_id=db_gift.book_id,
        status=db_gift.status,
        consent_given=db_gift.consent_given,
        purpose=db_gift.purpose,
        data_retention_until=db_gift.data_retention_until,
        created_at=db_gift.created_at
    )


@router.get("/", response_model=List[GiftInfo],
           summary="Get all gift orders",
           description="This endpoint retrieves all gift orders from the database",
           response_description="A list of all gift orders")
def read_gifts(db: Session = Depends(get_db)):
    gifts = db.query(Gift).all()
    return [GiftInfo(**gift.__dict__) for gift in gifts]


@router.get("/{gift_id}", response_model=GiftInfo,
           summary="Get a gift order",
           description="This endpoint retrieves a specific gift order by ID with GDPR logging",
           response_description="The gift order information")
def read_gift(gift_id: int, db: Session = Depends(get_db), request: Request = None):
    gift = db.query(Gift).filter(Gift.id == gift_id).first()
    if not gift:
        raise HTTPException(status_code=404, detail="Gift order not found")
    
    # Log data access
    log_data_access(db, gift_id, "READ", request, "gift_order_retrieval")
    
    # Get decrypted recipient data (in production, this would require authorization)
    recipient_data = gift.get_recipient_data()
    
    return GiftInfo(
        id=gift.id,
        book_id=gift.book_id,
        status=gift.status,
        consent_given=gift.consent_given,
        purpose=gift.purpose,
        data_retention_until=gift.data_retention_until,
        created_at=gift.created_at,
        recipient_data=recipient_data
    )


# GDPR Rights Endpoints

@router.post("/gdpr/access", response_model=List[GiftInfo],
            summary="GDPR Right to Access",
            description="Retrieve all gift data for a data subject")
def gdpr_access_request(
    data_request: GiftDataRequest,
    db: Session = Depends(get_db),
    request: Request = None
):
    """
    GDPR Article 15 - Right of access by the data subject
    Returns all gift orders containing the subject's data
    """
    # In production, implement proper identity verification here
    
    # Find gifts containing this data subject's information
    gifts = db.query(Gift).all()
    result = []
    
    for gift in gifts:
        recipient_data = gift.get_recipient_data()
        # Simple check - in production use more sophisticated matching
        if (data_request.subject_identifier.lower() in recipient_data.get("name", "").lower() or
            data_request.subject_identifier.lower() in recipient_data.get("address", "").lower()):
            
            # Log the access request
            log_data_access(db, gift.id, "GDPR_ACCESS", request, "gdpr_subject_access")
            
            result.append(GiftInfo(
                id=gift.id,
                book_id=gift.book_id,
                status=gift.status,
                consent_given=gift.consent_given,
                purpose=gift.purpose,
                data_retention_until=gift.data_retention_until,
                created_at=gift.created_at,
                recipient_data=recipient_data
            ))
    
    return result


@router.put("/gdpr/rectify/{gift_id}", response_model=GiftInfo,
           summary="GDPR Right to Rectification",
           description="Update/correct gift recipient data")
def gdpr_rectify_request(
    gift_id: int,
    updated_data: GiftCreate,
    db: Session = Depends(get_db),
    request: Request = None
):
    """
    GDPR Article 16 - Right to rectification
    Allows data subjects to correct their personal data
    """
    gift = db.query(Gift).filter(Gift.id == gift_id).first()
    if not gift:
        raise HTTPException(status_code=404, detail="Gift order not found")
    
    # Update the recipient data with encryption
    gift.set_recipient_data(updated_data.recipient_name, updated_data.recipient_address, updated_data.recipient_country)
    
    db.commit()
    db.refresh(gift)
    
    # Log the rectification
    log_data_access(db, gift_id, "GDPR_RECTIFY", request, "gdpr_data_rectification")
    
    return GiftInfo(
        id=gift.id,
        book_id=gift.book_id,
        status=gift.status,
        consent_given=gift.consent_given,
        purpose=gift.purpose,
        data_retention_until=gift.data_retention_until,
        created_at=gift.created_at,
        recipient_data=gift.get_recipient_data()
    )


@router.delete("/gdpr/erase/{gift_id}",
              summary="GDPR Right to Erasure",
              description="Delete gift data (right to be forgotten)")
def gdpr_erase_request(
    gift_id: int,
    db: Session = Depends(get_db),
    request: Request = None
):
    """
    GDPR Article 17 - Right to erasure ('right to be forgotten')
    Permanently deletes personal data
    """
    gift = db.query(Gift).filter(Gift.id == gift_id).first()
    if not gift:
        raise HTTPException(status_code=404, detail="Gift order not found")
    
    # Log the erasure before deleting
    log_data_access(db, gift_id, "GDPR_ERASE", request, "gdpr_data_erasure")
    
    # Delete the gift order and all associated data
    db.delete(gift)
    db.commit()
    
    return {"message": f"Gift order {gift_id} and all associated personal data has been permanently deleted"}


@router.get("/gdpr/retention-info", response_model=List[DataRetentionInfo],
           summary="Data Retention Information",
           description="Show data retention information for transparency")
def get_retention_info(db: Session = Depends(get_db)):
    """
    Provides transparency about data retention periods
    Required for GDPR compliance
    """
    gifts = db.query(Gift).filter(Gift.data_retention_until.isnot(None)).all()
    result = []
    
    for gift in gifts:
        days_remaining = (gift.data_retention_until - datetime.utcnow()).days
        result.append(DataRetentionInfo(
            gift_id=gift.id,
            created_at=gift.created_at,
            retention_until=gift.data_retention_until,
            days_remaining=max(0, days_remaining),
            auto_delete_enabled=True
        ))
    
    return result


@router.put("/gdpr/consent/{gift_id}", response_model=GiftInfo,
           summary="Update Consent Status",
           description="Allow users to withdraw or modify consent")
def update_consent(
    gift_id: int,
    consent_update: ConsentUpdate,
    db: Session = Depends(get_db),
    request: Request = None
):
    """
    GDPR Article 7 - Consent management
    Users can withdraw consent at any time
    """
    gift = db.query(Gift).filter(Gift.id == gift_id).first()
    if not gift:
        raise HTTPException(status_code=404, detail="Gift order not found")
    
    gift.consent_given = consent_update.consent_given
    gift.consent_timestamp = consent_update.consent_timestamp
    
    # If consent is withdrawn, schedule for deletion
    if not consent_update.consent_given:
        gift.data_retention_until = datetime.utcnow() + timedelta(days=30)  # Grace period
        gift.status = "consent_withdrawn"
    
    db.commit()
    
    # Log consent change
    log_data_access(db, gift_id, "CONSENT_UPDATE", request, "gdpr_consent_management")
    
    return GiftInfo(
        id=gift.id,
        book_id=gift.book_id,
        status=gift.status,
        consent_given=gift.consent_given,
        purpose=gift.purpose,
        data_retention_until=gift.data_retention_until,
        created_at=gift.created_at
    )
