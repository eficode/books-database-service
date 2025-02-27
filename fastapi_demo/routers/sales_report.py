from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import SalesReport, BookReport

router = APIRouter()

@router.get("/sales-report", response_model=SalesReport)
def get_sales_report(db: Session = Depends(get_db)):
    most_sold_books = db.query(Book).order_by(Book.sales.desc()).limit(10).all()
    least_sold_books = db.query(Book).order_by(Book.sales.asc()).limit(10).all()
    return {
        "most_sold_books": [
            BookReport(title=book.title, author=book.author, sales=book.sales)
            for book in most_sold_books
        ],
        "least_sold_books": [
            BookReport(title=book.title, author=book.author, sales=book.sales)
            for book in least_sold_books
        ]
    }
