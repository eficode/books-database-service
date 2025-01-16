from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book, SalesData
from ..dtos import MostSoldBooksResponse, MostSoldBook

router = APIRouter()

@router.get("/sales/most-sold-books", response_model=MostSoldBooksResponse)
def get_most_sold_books(db: Session = Depends(get_db)):
    sales_data = db.query(SalesData).order_by(SalesData.sales.desc()).all()
    books = []
    for data in sales_data:
        book = db.query(Book).filter(Book.id == data.book_id).first()
        if book:
            books.append(MostSoldBook(title=book.title, author=book.author, sales=data.sales))
    return MostSoldBooksResponse(books=books)