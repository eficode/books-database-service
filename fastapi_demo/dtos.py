from pydantic import BaseModel

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    sales_volume: int

    class Config:
        orm_mode = True
