from pydantic import BaseModel, Field
from typing import List

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BookCreate):
    id: int

    class Config:
        orm_mode = True

class BookImportResponse(BaseModel):
    message: str
    imported_count: int

class BookImportErrorResponse(BaseModel):
    error: str
    details: List[str]
