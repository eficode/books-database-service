from .database import Base
from sqlalchemy import Column, Integer, String, Boolean
from pydantic import BaseModel
from typing import Optional

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
    product_id = Column(Integer, index=True)
    user_id = Column(Integer, index=True)
    status = Column(String, default="pending")

class OrderCreate(BaseModel):
    product_id: int
    user_id: int

class OrderInfo(OrderCreate):
    id: Optional[int] = None
    status: Optional[str] = None
