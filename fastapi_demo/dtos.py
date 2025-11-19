from pydantic import BaseModel, validator
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    category: str = "Fiction"
    favorite: bool = False
    isbn: str

    @validator('isbn')
    def isbn_must_be_valid(cls, v):
        if len(v) not in [10, 13]:
            raise ValueError('ISBN must be either 10 or 13 characters long')
        return v

class BookInfo(BookCreate):
    id: Optional[int] = None

class BookFavorite(BaseModel):
    favorite: bool

class BookUpdate(BaseModel):
    title: Optional[str] = None
    author: Optional[str] = None
    pages: Optional[int] = None
    category: Optional[str] = None
    favorite: Optional[bool] = None
    isbn: Optional[str] = None

    @validator('isbn')
    def isbn_must_be_valid(cls, v):
        if v and len(v) not in [10, 13]:
            raise ValueError('ISBN must be either 10 or 13 characters long')
        return v