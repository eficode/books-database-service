from pydantic import BaseModel
from typing import Optional, List

class ReviewCreate(BaseModel):
    user: str
    review: str
    rating: int

class ReviewInfo(ReviewCreate):
    id: Optional[int] = None

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BookCreate):
    id: Optional[int] = None
    reviews: List[ReviewInfo] = []