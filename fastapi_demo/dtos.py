from pydantic import BaseModel, constr
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    color: constr(regex=r'^[a-zA-Z]+$')  # New attribute for color

class BookInfo(BookCreate):
    id: Optional[int] = None

class BookUpdate(BaseModel):
    title: Optional[str] = None
    author: Optional[str] = None
    pages: Optional[int] = None
    color: Optional[str] = None  # New attribute for color
