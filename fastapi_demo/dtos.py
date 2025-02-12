from pydantic import BaseModel

class OrderStatus(BaseModel):
    order_id: int
    logistical_status: str
    estimated_delivery_date: str
