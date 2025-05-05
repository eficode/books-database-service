from pydantic import BaseModel

class OrderCreate(BaseModel):
    customer_id: int
    book_id: int
    boosted_delivery: bool

class OrderInfo(BaseModel):
    order_id: int
    customer_id: int
    book_id: int
    status: str
    estimated_delivery_time: str
