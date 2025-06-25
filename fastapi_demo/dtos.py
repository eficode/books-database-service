from pydantic import BaseModel
from typing import Optional, List

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BookCreate):
    id: Optional[int] = None

class AuthorBooks(BaseModel):
    author: str
    books: List[BookInfo]
