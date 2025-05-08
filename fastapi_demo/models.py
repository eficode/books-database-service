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

class MothersDayPresent(Base):
    __tablename__ = 'mothers_day_presents'
    id = Column(Integer, primary_key=True, index=True)
    present_id = Column(Integer, ForeignKey('presents.id'))
    recipient_name = Column(String, index=True)
    recipient_address = Column(String)
    status = Column(String, default='pending')
