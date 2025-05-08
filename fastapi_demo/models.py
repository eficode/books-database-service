from .database import Base
from sqlalchemy import Column, Integer, String, Float, Date

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    category = Column(String, index=True, default="Fiction")
    favorite = Column(Boolean, default=False, index=True)

class SalesData(Base):
    __tablename__ = "sales_data"
    id = Column(Integer, primary_key=True, index=True)
    date = Column(Date, index=True)
    product_category = Column(String, index=True)
    region = Column(String, index=True)
    sales = Column(Float)
