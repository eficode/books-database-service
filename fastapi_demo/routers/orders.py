from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Order
from fastapi_demo.dtos import OrderStatus
import requests

router = APIRouter()

@router.get("/orders/{order_id}/status", response_model=OrderStatus)
def get_order_status(order_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Fetch order details from the database
    order = db.query(Order).filter(Order.id == order_id).first()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")

    # Call the logistics API to get the status
    try:
        response = requests.get(f"https://logistics.api/status/{order_id}")
        response.raise_for_status()
    except requests.exceptions.RequestException:
        raise HTTPException(status_code=503, detail="Service is currently unavailable")

    logistics_data = response.json()
    return OrderStatus(order_id=order_id, logistical_status=logistics_data["status"], estimated_delivery_date=logistics_data["estimated_delivery_date"])

@router.get("/orders/{order_id}/status", response_model=OrderStatus)
def get_order_status(order_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Fetch order details from the database
    order = db.query(Order).filter(Order.id == order_id).first()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")

    # Call the logistics API to get the status
    try:
        response = requests.get(f"https://logistics.api/status/{order_id}")
        response.raise_for_status()
    except requests.exceptions.RequestException:
        raise HTTPException(status_code=503, detail="Service is currently unavailable")

    logistics_data = response.json()
    return OrderStatus(order_id=order_id, logistical_status=logistics_data["status"], estimated_delivery_date=logistics_data["estimated_delivery_date"])

@router.get("/orders/{order_id}/status", response_model=OrderStatus)
def get_order_status(order_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Fetch order details from the database
    order = db.query(Order).filter(Order.id == order_id).first()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")

    # Call the logistics API to get the status
    try:
        response = requests.get(f"https://logistics.api/status/{order_id}")
        response.raise_for_status()
    except requests.exceptions.RequestException:
        raise HTTPException(status_code=503, detail="Service is currently unavailable")

    logistics_data = response.json()
    return OrderStatus(order_id=order_id, logistical_status=logistics_data["status"], estimated_delivery_date=logistics_data["estimated_delivery_date"])

@router.get("/orders/{order_id}/status", response_model=OrderStatus)
def get_order_status(order_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Fetch order details from the database
    order = db.query(Order).filter(Order.id == order_id).first()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")

    # Call the logistics API to get the status
    try:
        response = requests.get(f"https://logistics.api/status/{order_id}")
        response.raise_for_status()
    except requests.exceptions.RequestException:
        raise HTTPException(status_code=503, detail="Service is currently unavailable")

    logistics_data = response.json()
    return OrderStatus(order_id=order_id, logistical_status=logistics_data["status"], estimated_delivery_date=logistics_data["estimated_delivery_date"])
