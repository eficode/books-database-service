from .database import Base
from sqlalchemy import Column, Integer, String, Boolean, DateTime

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    category = Column(String, index=True, default="Fiction")
    favorite = Column(Boolean, default=False, index=True)

class GiftOrder(Base):
    __tablename__ = "gift_orders"
    id = Column(Integer, primary_key=True, index=True)
    gift_id = Column(Integer, index=True)
    recipient_name = Column(String, index=True)
    recipient_address = Column(String)
    status = Column(String, default="pending")
    delivery_date = Column(DateTime, nullable=True)
