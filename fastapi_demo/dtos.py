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
    category: str
    favorite: bool

class BookFavorite(BaseModel):
    favorite: bool

class AcademicLiteratureInfo(BaseModel):
    title: str
    author: str
    publication_year: int
