from pydantic import BaseModel

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    rating: float

    class Config:
        orm_mode = True
