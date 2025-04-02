from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    category_id: Optional[int] = None

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    category_id: Optional[int] = None

class BookFavorite(BaseModel):
    favorite: bool

class CategoryCreate(BaseModel):
    name: str

class CategoryInfo(BaseModel):
    id: int
    name: str