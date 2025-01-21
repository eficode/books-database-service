from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from ..database import get_db
from ..models import Book
from ..dtos import MostSoldBook
from typing import List

router = APIRouter()

@router.get("/sales/most-sold-books", response_model=List[MostSoldBook],
    summary="Fetch the most sold books from the previous week",
    description="This endpoint retrieves the most sold books from the previous week and returns their details and sold count",
    response_description="A list of the most sold books with their details and sold count")
def get_most_sold_books(db: Session = Depends(get_db)):
    one_week_ago = datetime.now() - timedelta(days=7)
    sales_data = db.query(
        Book.id,
        Book.title,
        Book.author,
        Book.pages,
        func.count(Book.id).label('sold_count')
    ).filter(
        Book.sale_date >= one_week_ago
    ).group_by(
        Book.id,
        Book.title,
        Book.author,
        Book.pages
    ).order_by(
        func.count(Book.id).desc()
    ).all()

    if not sales_data:
        raise HTTPException(status_code=404, detail="No sales data found for the last week")

    return sales_data
