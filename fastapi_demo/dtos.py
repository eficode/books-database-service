from pydantic import BaseModel
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

class GiftOrderCreate(BaseModel):
    gift_id: int
    recipient_name: str
    recipient_address: str
    message: str

class GiftOrderInfo(BaseModel):
    id: int
    gift_id: int
    recipient_name: str
    recipient_address: str
    message: str
    status: str
    dispatch_date: Optional[str] = None

class GiftOrderStatus(BaseModel):
    id: int
    status: str
    dispatch_date: Optional[str] = None
