from .database import Base
from sqlalchemy import Column, Integer, String, ForeignKey

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)

class Category(Base):
    __tablename__ = "categories"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)

class BookCategory(Base):
    __tablename__ = "book_categories"
    id = Column(Integer, primary_key=True, index=True)
    book_id = Column(Integer, ForeignKey('books.id'))
    category_id = Column(Integer, ForeignKey('categories.id'))
