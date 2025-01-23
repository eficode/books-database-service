from .database import Base
from sqlalchemy import Column, Integer, String, Float

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    isbn = Column(String, unique=True, index=True)
    genre = Column(String, index=True)
    price = Column(Float)
