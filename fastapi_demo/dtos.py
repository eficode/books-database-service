from pydantic import BaseModel
from typing import List

class SalesInfo(BaseModel):
    id: int
    book_id: int
    date_sold: str
    sales: int

    class Config:
        orm_mode = True

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    genre: str
    pages: int
    sales: List[SalesInfo]

    class Config:
        orm_mode = True
