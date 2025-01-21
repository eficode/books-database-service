from .database import Base
from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    sale_date = Column(DateTime, default=datetime.utcnow)
