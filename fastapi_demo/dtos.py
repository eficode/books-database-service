from pydantic import BaseModel
from typing import Optional


class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    category: str = "Fiction"
    favorite: bool = False

class BookInfo(BookCreate):
    id: Optional[int] = None
    cover_image: Optional[str] = None  # Assuming cover image URL is stored in the database

class BookFavorite(BaseModel):
    book_id: int
    favorite: bool
    favorite: bool
