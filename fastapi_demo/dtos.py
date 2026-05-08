from pydantic import BaseModel

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BookCreate):
    id: int

    class Config:
        orm_mode = True

class BookFavorite(BaseModel):
    favorite: bool

class FavoriteCreate(BaseModel):
    book_id: int

class FavoriteInfo(FavoriteCreate):
    id: int
    user_id: int

    class Config:
        orm_mode = True
