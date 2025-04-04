from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Order, OrderCreate, OrderInfo
from fastapi_demo.auth import is_authenticated

router = APIRouter()

@router.post("/order-immediately/", response_model=OrderInfo)
def order_immediately(order: OrderCreate, db: Session = Depends(get_db)):
    # Check if the user is authenticated
    if not is_authenticated(order.user_id):
        raise HTTPException(status_code=401, detail="Unauthorized")
    # Create a new order
    db_order = Order(**order.dict())
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return OrderInfo(**db_order.__dict__)
