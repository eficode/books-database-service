from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    category: str = "Fiction"
    favorite: bool = False
    synopsis: Optional[str] = None  # New field for synopsis

class BookInfo(BookCreate):
    id: Optional[int] = None

class BookFavorite(BaseModel):
    favorite: bool
