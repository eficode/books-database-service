from pydantic import BaseModel

class GiftCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: str

class GiftInfo(BaseModel):
    gift_id: int
    book_id: int
    recipient_name: str
    recipient_address: str
    status: str

    class Config:
        orm_mode = True
