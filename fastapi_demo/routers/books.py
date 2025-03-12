from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo

router = APIRouter()

@router.get("/top-selling-sports-books/", response_model=List[BookInfo])
def get_top_selling_sports_books(db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.category == 'Sports').order_by(Book.sales.desc()).limit(10).all()
    if not books:
        raise HTTPException(status_code=404, detail="Mother's Day gift section not available")
    return [BookInfo(**book.__dict__) for book in books]

@router.post("/quick-purchase/", response_model=Dict[str, Any])
def quick_purchase(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    if book.stock <= 0:
        raise HTTPException(status_code=400, detail="Book is out of stock")
    # Logic to add book to cart (assuming a Cart model exists)
    cart_id = add_book_to_cart(book_id)
    return {"message": "Book added to cart successfully", "cart_id": cart_id}
