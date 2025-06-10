from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/inventory/dashboard", response_model=List[BookInfo])
def get_inventory_dashboard(db: Session = Depends(get_db)):
    books = db.query(Book).all()
    book_list = []
    for book in books:
        reorder_needed = book.stock_level < book.reorder_threshold
        book_info = BookInfo(
            id=book.id,
            title=book.title,
            author=book.author,
            pages=book.pages,
            stock_level=book.stock_level,
            reorder_needed=reorder_needed
        )
        book_list.append(book_info)
    return {"books": book_list}
