from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
  title: str
  author: str
  pages: int
  category: Optional[str] = "Fiction"
  favorite: Optional[bool] = False

class BookInfo(BaseModel):
  id: int
  title: str
  author: str
  pages: int
  category: str
  favorite: bool

class BookFavorite(BaseModel):
  favorite: bool

class BookCover(BaseModel):
  book_id: int
  cover_image_url: Optional[str] = None
