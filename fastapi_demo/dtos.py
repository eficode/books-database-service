from pydantic import BaseModel
from typing import Optional
from datetime import date


class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    category: str = "Fiction"
    favorite: bool = False
    published_date: date

class BookInfo(BookCreate):
    id: Optional[int] = None

class BookFavorite(BaseModel):
    favorite: bool
