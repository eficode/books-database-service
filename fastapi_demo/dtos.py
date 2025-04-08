from pydantic import BaseModel
from typing import Optional, List

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

class FavoriteCreate(BaseModel):
    book_id: int

class FavoriteInfo(BaseModel):
    id: int
    user_id: int
    book_id: int
    title: str
    author: str
    cover_image: str

class CartCreate(BaseModel):
    book_id: int

class CartInfo(BaseModel):
    id: int
    user_id: int
    book_id: int
