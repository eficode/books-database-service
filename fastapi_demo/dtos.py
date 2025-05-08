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
    user_id: int
    book_id: int
    delivery_address: str
    delivery_date: str

class GiftInfo(GiftCreate):
    id: Optional[int] = None
    status: Optional[str] = None
