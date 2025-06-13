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

class BookFavorite(BaseModel):
    favorite: bool

class GiftCreate(BaseModel):
    book_id: int
    friend_name: str
    friend_address: str

class GiftInfo(GiftCreate):
    id: Optional[int] = None
    status: Optional[str] = None