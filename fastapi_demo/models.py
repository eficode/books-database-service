from .database import Base
from sqlalchemy import Column, Integer, String, DateTime
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    category = Column(String, index=True, default="Fiction")
    favorite = Column(Boolean, default=False, index=True)

class TestData(Base):
    __tablename__ = "test_data"
    id = Column(Integer, primary_key=True, index=True)
    data = Column(String, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class TestDataInfo(BaseModel):
    id: Optional[int] = None
    data: str
    created_at: datetime
