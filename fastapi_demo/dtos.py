from pydantic import BaseModel
from datetime import date

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    category: str
    sales: int
    date: date

    class Config:
        orm_mode = True
