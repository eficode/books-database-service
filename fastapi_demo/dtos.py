from pydantic import BaseModel

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int

class BookFavorite(BaseModel):
    favorite: bool

class RankingCreate(BaseModel):
    book_id: int
    rank: int

class RankingInfo(BaseModel):
    book_id: int
    title: str
    author: str
    pages: int
    rank: int