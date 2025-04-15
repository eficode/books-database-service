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

class OrderCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: str

class OrderInfo(OrderCreate):
    id: Optional[int] = None
    status: Optional[str] = None
