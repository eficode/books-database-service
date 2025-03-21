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

class AcademicLiterature(Base):
    __tablename__ = "academic_literature"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    publication_year = Column(Integer)
    related_book_id = Column(Integer, index=True)
