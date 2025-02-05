from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    genre: str
    publication_date: str
    pages: int

class BookInfo(BookCreate):
    id: Optional[int] = None
