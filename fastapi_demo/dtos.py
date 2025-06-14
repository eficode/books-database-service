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