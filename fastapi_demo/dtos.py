from pydantic import BaseModel
from typing import List, Optional

class BookSales(BaseModel):
    title: str
    author: str
    sales_volume: int

class GenreSales(BaseModel):
    genre: str
    books: List[BookSales]

class SalesReport(BaseModel):
    report: List[GenreSales]
