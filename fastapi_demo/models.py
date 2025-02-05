from .database import Base
from sqlalchemy import Column, Integer, String, Date

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    category = Column(String, index=True)
    sales = Column(Integer)
    date = Column(Date)
