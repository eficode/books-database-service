from .database import Base
from sqlalchemy import Column, Integer, String, Boolean

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    category = Column(String, index=True, default="Fiction")
    favorite = Column(Boolean, default=False, index=True)

class UserBonus(Base):
    __tablename__ = "user_bonus"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    bonus_points = Column(Integer, default=0)

class BookProgress(Base):
    __tablename__ = "book_progress"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    book_id = Column(Integer, index=True)
    progress = Column(Integer, default=0)
