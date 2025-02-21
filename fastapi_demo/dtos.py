from pydantic import BaseModel

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    publication_date: str

    class Config:
        orm_mode = True
