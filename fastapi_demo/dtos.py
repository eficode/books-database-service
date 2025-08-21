from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    genre: str  # New field

class BookUpdate(BaseModel):
    title: Optional[str] = None
    author: Optional[str] = None
    pages: Optional[int] = None
    genre: Optional[str] = None  # New field

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    genre: str  # New field

class BookFavorite(BaseModel):
    favorite: bool
