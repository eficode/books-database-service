from pydantic import BaseModel, Field
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    category: str = "Fiction"
    favorite: bool = False

class BookInfo(BookCreate):
    id: Optional[int] = None

class BookFavorite(BaseModel):
    favorite: bool

class PaymentDetails(BaseModel):
    card_number: str
    expiry_date: str
    cvv: str

class GiftCreate(BaseModel):
    gift_id: int
    mother_name: str
    mother_address: str
    mother_city: str
    mother_country: str
    payment_details: PaymentDetails

class GiftInfo(BaseModel):
    order_id: int
    status: str
    shipping_details: Optional[dict] = None
