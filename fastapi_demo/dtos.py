from pydantic import BaseModel
from typing import Optional

class BookInfo(BaseModel):
    id: Optional[int]
    title: str
    author: str
    pages: int
    sales_rank: int
    category: str
