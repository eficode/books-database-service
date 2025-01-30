from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    color: str  # New attribute

class BookInfo(BookCreate):
    id: Optional[int] = None
