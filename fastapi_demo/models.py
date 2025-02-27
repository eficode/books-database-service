from .database import Base
from sqlalchemy import Column, Integer, String
from sqlalchemy import Index

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)

Index('idx_title_author', Book.title, Book.author)