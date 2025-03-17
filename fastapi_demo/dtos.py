from pydantic import BaseModel, Field, validator
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
    favorite: bool

class CommentCreate(BaseModel):
    book_id: int
    user_id: int
    content: str = Field(..., min_length=1, description="The content of the comment")

class CommentInfo(CommentCreate):
    id: Optional[int] = None
