from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    sales: Optional[int] = 0
    rating: Optional[float] = 0.0
    date_sold: Optional[str] = None

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    sales: int
    rating: float
    date_sold: Optional[str]
    date_created: str
