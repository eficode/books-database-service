from pydantic import BaseModel
from typing import Optional

class SubscriptionCreate(BaseModel):
    user_id: int
    delivery_details: dict
    payment_info: dict

class DeliveryStatus(BaseModel):
    subscription_id: int
    book_id: Optional[int]
    delivery_status: str
