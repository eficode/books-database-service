from datetime import datetime
from .database import Base
from sqlalchemy import Column, Integer, String, Boolean, Date, func


class Book(Base):
    __tablename__ = "books"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    category = Column(String, index=True, default="Fiction")
    favorite = Column(Boolean, default=False, index=True)
    added_date = Column(Date, default=func.now())
