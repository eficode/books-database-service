from pydantic import BaseModel

class FavouriteCreate(BaseModel):
    book_id: int

class FavouriteInfo(BaseModel):
    id: int
    user_id: int
    book_id: int
    class Config:
        orm_mode = True
