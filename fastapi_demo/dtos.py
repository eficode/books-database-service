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

class GiftCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: str
    recipient_city: str
    recipient_postcode: str

class GiftInfo(GiftCreate):
    gift_id: Optional[int] = None
    status: Optional[str] = None
