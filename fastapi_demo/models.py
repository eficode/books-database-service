from .database import Base
from sqlalchemy import Column, Integer, String, ForeignKey, Date
from sqlalchemy.orm import relationship

class Sales(Base):
    __tablename__ = 'sales'
    id = Column(Integer, primary_key=True, index=True)
    book_id = Column(Integer, ForeignKey('books.id'))
    date_sold = Column(Date)
    sales = Column(Integer)

class Book(Base):
    __tablename__ = 'books'
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    genre = Column(String, index=True)
    pages = Column(Integer)
    sales = relationship('Sales', back_populates='book')
