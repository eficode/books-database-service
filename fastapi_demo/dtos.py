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

class FavouriteCreate(BaseModel):
    book_id: int

class FavouriteInfo(BaseModel):
    id: int
    user_id: int
    book_id: int
    book_title: str
    book_author: str

class ReorderFavourite(BaseModel):
    id: int
    new_position: int

class ReorderFavouriteResponse(BaseModel):
    id: int
    user_id: int
    book_id: int
    position: int
