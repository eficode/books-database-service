from pydantic import BaseModel

class GiftOrderCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: str
    recipient_contact: str

class GiftOrderInfo(BaseModel):
    id: int
    book_id: int
    recipient_name: str
    recipient_address: str
    recipient_contact: str
    status: str

    class Config:
        orm_mode = True
