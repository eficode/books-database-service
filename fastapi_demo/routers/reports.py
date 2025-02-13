from fastapi import APIRouter, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..utils import get_least_sold_books, generate_report, send_email

router = APIRouter()

@router.post('/reports/least-sold-books', summary='Generate Report for Least Sold Books', description='This endpoint initiates the generation of a report for the top 10 least sold books', response_description='Report generation initiated')
def generate_least_sold_books_report(db: Session = Depends(get_db)):
    books = get_least_sold_books(db)
    report = generate_report(books)
    send_email('sales_manager@bookbridge.com', 'Top 10 Least Sold Books', report)
    return {'message': 'Report generation initiated'}
