from .database import Base
from sqlalchemy import Column, Integer, String, Float

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    sales = Column(Integer, default=0)
    ratings = Column(Float, default=0.0)
    publication_date = Column(String)
