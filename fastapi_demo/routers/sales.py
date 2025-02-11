from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book, Sales
from ..dtos import SalesReport
from ..email_service import send_email_report
from sqlalchemy import func

router = APIRouter()

@router.get("/sales/daily-report", response_model=SalesReport)
def get_daily_report(db: Session = Depends(get_db)):
    sales_data = db.query(
        Book.genre,
        Book.title,
        Book.author,
        func.sum(Sales.volume).label('sales_volume')
    ).join(Sales, Book.id == Sales.book_id)
    .group_by(Book.genre, Book.title, Book.author)
    .order_by(Book.genre, func.sum(Sales.volume).desc())
    .all()

    if not sales_data:
        return {"report": []}

    report = []
    for genre, title, author, sales_volume in sales_data:
        report.append({
            "genre": genre,
            "books": [{
                "title": title,
                "author": author,
                "sales_volume": sales_volume
            }]
        })

    return {"report": report}
