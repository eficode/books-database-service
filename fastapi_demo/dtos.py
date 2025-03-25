from pydantic import BaseModel

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    sales: int

    class Config:
        orm_mode = True
