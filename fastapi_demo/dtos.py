from pydantic import BaseModel
from datetime import datetime

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    sale_date: datetime

    class Config:
        orm_mode = True

class MostSoldBook(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    sold_count: int

    class Config:
        orm_mode = True
