from pydantic import BaseModel
from typing import List

class BookSalesInfo(BaseModel):
    id: int
    title: str
    author: str
    sales: int

    class Config:
        orm_mode = True

class BookSalesResponse(BaseModel):
    books: List[BookSalesInfo]
