from pydantic import BaseModel, Field

class BookCreate(BaseModel):
    title: str
    author: str
    pages: int

class BookInfo(BaseModel):
    id: int
    title: str
    author: str
    pages: int
    category: str
    favorite: bool

class BookFavorite(BaseModel):
    favorite: bool

class GiftCreate(BaseModel):
    name: str
    price: float
    description: str
    stock: int

class GiftInfo(BaseModel):
    id: int
    name: str
    price: float
    description: str
    stock: int

class CartCreate(BaseModel):
    gift_id: int
    quantity: int

class CartInfo(BaseModel):
    id: int
    gift_id: int
    quantity: int

class RecipientAddressCreate(BaseModel):
    cart_id: int
    recipient_name: str
    recipient_address: str

class RecipientAddressInfo(BaseModel):
    id: int
    cart_id: int
    recipient_name: str
    recipient_address: str

class OrderCreate(BaseModel):
    cart_id: int

class OrderInfo(BaseModel):
    id: int
    cart_id: int
    status: str

class EmailNotification(BaseModel):
    order_id: int
    email: str
