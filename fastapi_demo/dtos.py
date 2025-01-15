from pydantic import BaseModel
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    color: Optional[str] = None

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    color: Optional[str] = None

    class Config:
        orm_mode = True