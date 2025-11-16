from pydantic import BaseModel
from datetime import datetime

class CommentCreate(BaseModel):
    comment: str

class CommentInfo(BaseModel):
    id: int
    book_id: int
    user_id: int
    comment: str
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True