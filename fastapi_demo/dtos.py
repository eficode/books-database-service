from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    isbn: str
    genre: str
    price: float

class BookInfo(BookCreate):
    id: Optional[int] = None
