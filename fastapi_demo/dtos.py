from pydantic import BaseModel
from typing import Optional

class BookInfo(BaseModel):
    id: Optional[int] = None
    title: str
    author: str
    price: float
    pages: int