from .database import Base
from sqlalchemy import Column, Integer, String, Float, ForeignKey

class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    author = Column(String, index=True)
    pages = Column(Integer)
    stock = Column(Integer, default=0)

class ShoppingCart(Base):
    __tablename__ = "shopping_cart"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    book_id = Column(Integer, ForeignKey("books.id"))
    price = Column(Float)
