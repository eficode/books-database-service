from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, asc, desc
from typing import List, Optional

from ..database import get_db
from ..models import Basket, BasketItem, Book
from ..dtos import SoldBookInfo

router = APIRouter()

@router.get("/sold-books", response_model=List[SoldBookInfo])
def get_sold_books(
    db: Session = Depends(get_db),
    sort_by: Optional[str] = Query(None, description="Field to sort by (title, author, category, price, total_sold, revenue)"),
    sort_order: Optional[str] = Query("desc", description="Sort order (asc or desc)")
):
    """Get aggregated data of sold books from completed baskets"""
    
    # Normalize sort_order to lowercase
    sort_order = sort_order.lower() if sort_order else "desc"
    if sort_order not in ["asc", "desc"]:
        sort_order = "desc"
    
    # Query to get all sold books with their quantities
    query = db.query(
        Book.id,
        Book.title,
        Book.author,
        Book.category,
        Book.price,
        func.sum(BasketItem.quantity).label('total_sold')
    ).join(
        BasketItem, Book.id == BasketItem.book_id
    ).join(
        Basket, BasketItem.basket_id == Basket.id
    ).filter(
        Basket.completed == True
    ).group_by(
        Book.id,
        Book.title,
        Book.author,
        Book.category,
        Book.price
    )
    
    # Apply sorting based on sort_by parameter
    if sort_by == "title":
        query = query.order_by(asc(Book.title) if sort_order == "asc" else desc(Book.title))
    elif sort_by == "author":
        query = query.order_by(asc(Book.author) if sort_order == "asc" else desc(Book.author))
    elif sort_by == "category":
        query = query.order_by(asc(Book.category) if sort_order == "asc" else desc(Book.category))
    elif sort_by == "price":
        query = query.order_by(asc(Book.price) if sort_order == "asc" else desc(Book.price))
    elif sort_by == "revenue":
        # Revenue is calculated, so we need to sort by price * total_sold
        query = query.order_by(
            asc(Book.price * func.sum(BasketItem.quantity)) if sort_order == "asc" 
            else desc(Book.price * func.sum(BasketItem.quantity))
        )
    else:
        # Default sort by total_sold (or if sort_by is "total_sold" or invalid)
        query = query.order_by(
            asc(func.sum(BasketItem.quantity)) if sort_order == "asc" 
            else desc(func.sum(BasketItem.quantity))
        )
    
    sold_books = query.all()
    
    # Convert to DTOs
    result = []
    for book in sold_books:
        revenue = book.price * book.total_sold
        result.append(SoldBookInfo(
            id=book.id,
            title=book.title,
            author=book.author,
            category=book.category,
            price=book.price,
            total_sold=book.total_sold,
            revenue=round(revenue, 2)
        ))
    
    return result