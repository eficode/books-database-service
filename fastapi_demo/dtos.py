from pydantic import BaseModel

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int

    class Config:
        orm_mode = True

class GiftCreate(BaseModel):
    book_id: int
    recipient_name: str
    recipient_address: str
    personal_message: str
    gift_wrap_style: str

class GiftInfo(BaseModel):
    id: int
    book_id: int
    recipient_name: str
    recipient_address: str
    personal_message: str
    gift_wrap_style: str
    status: str

    class Config:
        orm_mode = True
