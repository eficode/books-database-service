from pydantic import BaseModel
from typing import Optional

class GiftCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: str
    recipient_country: str

class GiftInfo(GiftCreate):
    id: Optional[int] = None
    status: Optional[str] = None
