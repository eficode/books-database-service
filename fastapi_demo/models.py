from .database import Base
from sqlalchemy import Column, Integer, String, Date

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    publication_date = Column(Date, index=True)
    isbn = Column(String, index=True)
