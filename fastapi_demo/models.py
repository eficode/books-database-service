from .database import Base
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    category = Column(String, index=True, default="Fiction")
    favorite = Column(Boolean, default=False, index=True)

class Gift(Base):
    __tablename__ = "gifts"
    gift_id = Column(Integer, primary_key=True, index=True)
    book_id = Column(Integer, ForeignKey('books.id'), nullable=False)
    recipient_name = Column(String, nullable=False)
    recipient_address = Column(String, nullable=False)
    status = Column(String, default="Pending")
