from pydantic import BaseModel
from typing import Optional, List

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BookCreate):
    id: Optional[int] = None

class CategoryCreate(BaseModel):
    name: str

class CategoryInfo(CategoryCreate):
    id: Optional[int] = None

class BookCategoryCreate(BaseModel):
    book_id: int

class BookCategoryInfo(BookCategoryCreate):
    category_id: Optional[int] = None

class BookInfoInCategory(BaseModel):
    id: int
    title: str
    author: str
    pages: int
