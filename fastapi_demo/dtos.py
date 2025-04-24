from pydantic import BaseModel

class FavoriteCreate(BaseModel):
    user_id: int
    book_id: int

class FavoriteInfo(BaseModel):
    id: int
    user_id: int
    book_id: int
    class Config:
        orm_mode = True
