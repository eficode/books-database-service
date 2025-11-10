from pydantic import BaseModel
from typing import List

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int

class BookFavorite(BaseModel):
    favorite: bool

class FavoriteBookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int

class FavoriteBookCreate(BaseModel):
    book_id: int

class FavoriteBooksResponse(BaseModel):
    favorites: List[FavoriteBookInfo]
