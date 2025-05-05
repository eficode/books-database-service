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

class Gift(Base):
    __tablename__ = "gifts"
    gift_id = Column(Integer, primary_key=True, index=True)
    book_id = Column(Integer, index=True)
    recipient_name = Column(String, index=True)
    recipient_address = Column(String)
    recipient_city = Column(String)
    recipient_postcode = Column(String)
    status = Column(String, default="Pending")
