from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    delivered: Optional[bool] = False

class BookInfo(BookCreate):
    id: Optional[int] = None
