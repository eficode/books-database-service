from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BookCreate):
    id: Optional[int] = None

class SalesReport(BaseModel):
    book_id: int
    title: str
    author: str
    sales: int
