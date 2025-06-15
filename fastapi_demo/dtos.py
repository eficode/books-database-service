from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    category: str = "Fiction"
    favorite: bool = False
    price: float = 9.99

class BookInfo(BookCreate):
    id: Optional[int] = None

class BookFavorite(BaseModel):
    favorite: bool

class BasketItemInfo(BaseModel):
    id: int
    book_id: int
    quantity: int
    book: BookInfo

class BasketInfo(BaseModel):
    id: int
    created_at: datetime
    completed: bool
    items: List[BasketItemInfo]
    total: float

class AddToBasketRequest(BaseModel):
    book_id: int
    quantity: int = 1

class PurchaseResponse(BaseModel):
    basket_id: int
    total: float
    items: List[BasketItemInfo]
    purchase_date: datetime

class SoldBookInfo(BaseModel):
    id: int
    title: str
    author: str
    category: str
    price: float
    total_sold: int
    revenue: float


class GiftCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: str
    recipient_country: str
    consent_given: bool
    marketing_consent: Optional[bool] = False  # Separate consent for marketing


class GiftInfo(BaseModel):
    id: Optional[int] = None
    book_id: int
    status: Optional[str] = None
    consent_given: bool
    purpose: Optional[str] = None
    data_retention_until: Optional[datetime] = None
    created_at: Optional[datetime] = None
    
    # Recipient data only included if proper access controls are met
    recipient_data: Optional[dict] = None


class GiftDataRequest(BaseModel):
    """DTO for GDPR data subject requests"""
    request_type: str  # access, rectify, erase
    subject_identifier: str  # email or other identifier
    verification_code: Optional[str] = None


class ConsentUpdate(BaseModel):
    """DTO for updating consent preferences"""
    consent_given: bool
    marketing_consent: Optional[bool] = None
    consent_timestamp: datetime


class DataRetentionInfo(BaseModel):
    """DTO for data retention information"""
    gift_id: int
    created_at: datetime
    retention_until: datetime
    days_remaining: int
    auto_delete_enabled: bool