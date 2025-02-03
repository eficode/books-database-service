from pydantic import BaseModel

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int
    cover_color: str  # New field

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    cover_color: str  # New field

    class Config:
        orm_mode = True
