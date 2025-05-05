from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Order
from ..dtos import OrderCreate, OrderInfo
import random

router = APIRouter(
    prefix="/orders",
    tags=["orders"]
)

@router.post("/", response_model=OrderInfo,
    summary="Create a new order",
    description="This endpoint creates a new order with the provided details and returns the order information",
    response_description="The created order's information")
def create_order(
    order: OrderCreate = Body(..., description="The details of the order to be created"),
    db: Session = Depends(get_db)):
    estimated_delivery_time = "2023-10-10T10:00:00Z" if order.boosted_delivery else "2023-10-15T10:00:00Z"
    delivery_delayed = random.choice([True, False])
    notification_failed = random.choice([True, False])
    if delivery_delayed:
        estimated_delivery_time = "2023-10-20T10:00:00Z"
    db_order = Order(
        customer_id=order.customer_id,
        book_id=order.book_id,
        boosted_delivery=order.boosted_delivery,
        estimated_delivery_time=estimated_delivery_time,
        delivery_delayed=delivery_delayed,
        notification_failed=notification_failed
    )
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return OrderInfo(
        order_id=db_order.id,
        customer_id=db_order.customer_id,
        book_id=db_order.book_id,
        status=db_order.status,
        estimated_delivery_time=db_order.estimated_delivery_time
    )

@router.get("/{order_id}", response_model=OrderInfo,
    summary="Read an order",
    description="This endpoint retrieves the details of an order with the provided ID",
    response_description="The requested order's information")
def read_order(
    order_id: int = Path(..., description="The ID of the order to be retrieved"),
    db: Session = Depends(get_db)):
    db_order = db.query(Order).filter(Order.id == order_id).first()
    if db_order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    return OrderInfo(
        order_id=db_order.id,
        customer_id=db_order.customer_id,
        book_id=db_order.book_id,
        status=db_order.status,
        estimated_delivery_time=db_order.estimated_delivery_time
    )
