from pydantic import BaseModel
from typing import List

class BookReport(BaseModel):
    title: str
    author: str
    sales: int

class SalesReport(BaseModel):
    most_sold_books: List[BookReport]
    least_sold_books: List[BookReport]
