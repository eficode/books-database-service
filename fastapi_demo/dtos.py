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
    stock_level: int
    predicted_delivery_time: str

    class Config:
        orm_mode = True
