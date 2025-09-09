from pydantic import BaseModel
from typing import List

class BestsellerInfo(BaseModel):
    id: int
    title: str
    author: str
    price: float

    class Config:
        orm_mode = True

class CartAddRequest(BaseModel):
    book_id: int

class CheckoutRequest(BaseModel):
    payment_details: dict

class CheckoutResponse(BaseModel):
    message: str
    order_id: int

class BestsellersResponse(BaseModel):
    bestsellers: List[BestsellerInfo]