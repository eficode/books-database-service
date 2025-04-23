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
    id = Column(Integer, primary_key=True, index=True)
    gift_id = Column(Integer)
    user_id = Column(Integer)
    mother_name = Column(String)
    mother_address = Column(String)
    mother_city = Column(String)
    mother_country = Column(String)
    status = Column(String)
    tracking_number = Column(String)
    estimated_delivery = Column(String)
