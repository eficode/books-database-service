from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from ..database import get_db
from ..models import Sale, Book
from ..dtos import BookSalesResponse, BookSalesInfo
from sqlalchemy import func
from ..security import get_current_active_sales_manager

router = APIRouter()


def get_sales_data(db: Session, start_date: datetime, end_date: datetime):
    return db.query(Sale.book_id, func.sum(Sale.quantity).label('total_sales'))\
        .filter(Sale.sale_date.between(start_date, end_date))\
        .group_by(Sale.book_id)\
        .all()


def get_most_sold_books(db: Session):
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=7)
    sales_data = get_sales_data(db, start_date, end_date)
    sales_data.sort(key=lambda x: x.total_sales, reverse=True)
    return sales_data


def get_least_sold_books(db: Session):
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=7)
    sales_data = get_sales_data(db, start_date, end_date)
    sales_data.sort(key=lambda x: x.total_sales)
    return sales_data


@router.get("/sales/most-sold-books", response_model=BookSalesResponse, dependencies=[Depends(get_current_active_sales_manager)])
def fetch_most_sold_books(db: Session = Depends(get_db)):
    sales_data = get_most_sold_books(db)
    books = []
    for sale in sales_data:
        book = db.query(Book).filter(Book.id == sale.book_id).first()
        if book:
            books.append(BookSalesInfo(id=book.id, title=book.title, author=book.author, sales=sale.total_sales))
    return BookSalesResponse(books=books)


@router.get("/sales/least-sold-books", response_model=BookSalesResponse, dependencies=[Depends(get_current_active_sales_manager)])
def fetch_least_sold_books(db: Session = Depends(get_db)):
    sales_data = get_least_sold_books(db)
    books = []
    for sale in sales_data:
        book = db.query(Book).filter(Book.id == sale.book_id).first()
        if book:
            books.append(BookSalesInfo(id=book.id, title=book.title, author=book.author, sales=sale.total_sales))
    return BookSalesResponse(books=books)
