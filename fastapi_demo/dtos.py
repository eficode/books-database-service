from pydantic import BaseModel
from typing import Optional

class PaymentInfo(BaseModel):
    card_number: str
    expiry_date: str
    cvv: str

class GiftOrderCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: Optional[str]
    payment_info: PaymentInfo

class GiftOrderInfo(BaseModel):
    id: int
    book_id: int
    recipient_name: str
    recipient_address: str
    status: str

    class Config:
        orm_mode = True