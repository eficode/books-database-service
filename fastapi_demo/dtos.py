from pydantic import BaseModel
from typing import Optional, List

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BookCreate):
    id: Optional[int] = None

class MostSoldBook(BaseModel):
    title: str
    author: str
    sales: int

class MostSoldBooksResponse(BaseModel):
    books: List[MostSoldBook]