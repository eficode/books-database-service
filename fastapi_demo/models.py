from .database import Base
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from datetime import datetime

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    category = Column(String, index=True, default="Fiction")
    favorite = Column(Boolean, default=False, index=True)

class PurchaseGift(Base):
    __tablename__ = "purchase_gifts"
    id = Column(Integer, primary_key=True, index=True)
    book_id = Column(Integer, index=True)
    recipient_name = Column(String, index=True)
    recipient_address = Column(String)
    recipient_email = Column(String)
    status = Column(String, default="pending")
    purchase_date = Column(DateTime, default=datetime.utcnow)
    delivery_date = Column(DateTime, nullable=True)
