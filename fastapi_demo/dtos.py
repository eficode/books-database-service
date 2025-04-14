from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class GiftCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: str
    personal_message: Optional[str] = None

class GiftInfo(GiftCreate):
    id: int
    estimated_delivery_date: datetime
