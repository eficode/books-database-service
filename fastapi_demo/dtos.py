from pydantic import BaseModel
from typing import Optional

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    stock_level: int
    reorder_needed: bool

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    stock_level: int
    reorder_threshold: int

class BookUpdate(BaseModel):
    title: Optional[str] = None
    author: Optional[str] = None
    pages: Optional[int] = None
    stock_level: Optional[int] = None
    reorder_threshold: Optional[int] = None
