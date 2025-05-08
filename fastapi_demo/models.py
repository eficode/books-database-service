from .database import Base
from sqlalchemy import Column, Integer, String, Boolean, Float

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
    name = Column(String, index=True)
    price = Column(Float)
    description = Column(String)
    stock = Column(Integer, default=0)

class Cart(Base):
    __tablename__ = "carts"
    id = Column(Integer, primary_key=True, index=True)
    gift_id = Column(Integer)
    quantity = Column(Integer)

class RecipientAddress(Base):
    __tablename__ = "recipient_addresses"
    id = Column(Integer, primary_key=True, index=True)
    cart_id = Column(Integer)
    recipient_name = Column(String)
    recipient_address = Column(String)

class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True, index=True)
    cart_id = Column(Integer)
    status = Column(String)
