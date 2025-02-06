from pydantic import BaseModel
from typing import List, Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BookCreate):
    id: Optional[int] = None

class CartItem(BaseModel):
    book_id: int
    title: str
    price: float

class CartResponse(BaseModel):
    cart: List[CartItem]
