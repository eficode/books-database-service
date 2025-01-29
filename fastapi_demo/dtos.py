from pydantic import BaseModel
from datetime import datetime

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    release_date: datetime

    class Config:
        orm_mode = True
