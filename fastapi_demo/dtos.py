from pydantic import BaseModel, EmailStr

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

class SubscriptionCreate(BaseModel):
    email: EmailStr

class SubscriptionInfo(SubscriptionCreate):
    id: int
    confirmed: bool

    class Config:
        orm_mode = True
