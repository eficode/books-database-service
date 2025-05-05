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

class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, index=True)
    book_id = Column(Integer, index=True)
    boosted_delivery = Column(Boolean, default=False)
    status = Column(String, default="Processing")
    estimated_delivery_time = Column(String)
    delivery_delayed = Column(Boolean, default=False)
    notification_failed = Column(Boolean, default=False)
