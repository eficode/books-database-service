from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    sales: Optional[int] = 0
    ratings: Optional[float] = 0.0
    publication_date: str

class BookInfo(BookCreate):
    id: Optional[int] = None
