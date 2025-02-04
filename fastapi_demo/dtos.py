from pydantic import BaseModel

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    color: str

    class Config:
        orm_mode = True
