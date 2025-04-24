from pydantic import BaseModel
from typing import List

class FavoriteAuthorCreate(BaseModel):
    author_id: int

class FavoriteAuthorResponse(BaseModel):
    id: int
    user_id: int
    author_id: int

    class Config:
        orm_mode = True
