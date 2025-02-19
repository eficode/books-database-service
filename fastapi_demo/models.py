from .database import Base
from sqlalchemy import Column, Integer, String

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)

class Gift(Base):
    __tablename__ = "gifts"
    id = Column(Integer, primary_key=True, index=True)
    book_id = Column(Integer, index=True)
    recipient_name = Column(String, index=True)
    recipient_address = Column(String)
    personal_message = Column(String)
    gift_wrap_style = Column(String)
    status = Column(String, default='pending')
