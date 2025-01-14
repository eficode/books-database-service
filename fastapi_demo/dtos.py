from pydantic import BaseModel
from typing import Optional

class CategoryCreate(BaseModel):
    name: str

class CategoryInfo(BaseModel):
    id: int
    name: str

    class Config:
        orm_mode = True

class BookCategoryAssign(BaseModel):
    book_id: int
    category_id: int

class BookSearchByCategory(BaseModel):
    category_id: int
