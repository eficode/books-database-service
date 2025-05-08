from pydantic import BaseModel, EmailStr

class PurchaseGiftCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: str
    recipient_email: EmailStr

class PurchaseGiftResponse(BaseModel):
    purchase_id: int
    status: str
    message: str

class PurchaseGiftStatusResponse(BaseModel):
    purchase_id: int
    status: str
    book_id: int
    recipient_name: str
    recipient_address: str
    recipient_email: str
    purchase_date: str
    delivery_date: str
