from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime

from ..database import get_db
from ..models import Basket, BasketItem, Book
from ..dtos import BasketInfo, AddToBasketRequest, PurchaseResponse, BasketItemInfo, BookInfo

router = APIRouter()

def get_or_create_basket(db: Session) -> Basket:
    """Get the current active basket or create a new one"""
    basket = db.query(Basket).filter(Basket.completed == False).first()
    if not basket:
        basket = Basket()
        db.add(basket)
        db.commit()
        db.refresh(basket)
    return basket

def calculate_basket_total(basket: Basket) -> float:
    """Calculate the total price of all items in the basket"""
    total = 0.0
    for item in basket.items:
        total += item.book.price * item.quantity
    return round(total, 2)

def basket_to_dto(basket: Basket) -> BasketInfo:
    """Convert basket model to DTO"""
    items = []
    for item in basket.items:
        book_info = BookInfo(
            id=item.book.id,
            title=item.book.title,
            author=item.book.author,
            pages=item.book.pages,
            category=item.book.category,
            favorite=item.book.favorite,
            price=item.book.price
        )
        items.append(BasketItemInfo(
            id=item.id,
            book_id=item.book_id,
            quantity=item.quantity,
            book=book_info
        ))
    
    return BasketInfo(
        id=basket.id,
        created_at=basket.created_at,
        completed=basket.completed,
        items=items,
        total=calculate_basket_total(basket)
    )

@router.get("/", response_model=BasketInfo)
def get_current_basket(db: Session = Depends(get_db)):
    """Get the current shopping basket"""
    basket = get_or_create_basket(db)
    return basket_to_dto(basket)

@router.post("/add", response_model=BasketInfo)
def add_to_basket(request: AddToBasketRequest, db: Session = Depends(get_db)):
    """Add a book to the shopping basket"""
    # Check if book exists
    book = db.query(Book).filter(Book.id == request.book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    
    # Get or create basket
    basket = get_or_create_basket(db)
    
    # Check if book already in basket
    existing_item = db.query(BasketItem).filter(
        BasketItem.basket_id == basket.id,
        BasketItem.book_id == request.book_id
    ).first()
    
    if existing_item:
        # Update quantity
        existing_item.quantity += request.quantity
    else:
        # Create new basket item
        basket_item = BasketItem(
            basket_id=basket.id,
            book_id=request.book_id,
            quantity=request.quantity
        )
        db.add(basket_item)
    
    db.commit()
    db.refresh(basket)
    return basket_to_dto(basket)

@router.delete("/item/{item_id}", response_model=BasketInfo)
def remove_from_basket(item_id: int, db: Session = Depends(get_db)):
    """Remove an item from the basket"""
    item = db.query(BasketItem).filter(BasketItem.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Basket item not found")
    
    basket = item.basket
    db.delete(item)
    db.commit()
    db.refresh(basket)
    return basket_to_dto(basket)

@router.post("/purchase", response_model=PurchaseResponse)
def purchase_basket(db: Session = Depends(get_db)):
    """Complete the purchase of the current basket"""
    basket = db.query(Basket).filter(Basket.completed == False).first()
    if not basket or len(basket.items) == 0:
        raise HTTPException(status_code=400, detail="Basket is empty")
    
    # Calculate total
    total = calculate_basket_total(basket)
    
    # Create response before marking as completed
    items = []
    for item in basket.items:
        book_info = BookInfo(
            id=item.book.id,
            title=item.book.title,
            author=item.book.author,
            pages=item.book.pages,
            category=item.book.category,
            favorite=item.book.favorite,
            price=item.book.price
        )
        items.append(BasketItemInfo(
            id=item.id,
            book_id=item.book_id,
            quantity=item.quantity,
            book=book_info
        ))
    
    # Mark basket as completed
    basket.completed = True
    db.commit()
    
    return PurchaseResponse(
        basket_id=basket.id,
        total=total,
        items=items,
        purchase_date=datetime.utcnow()
    )

@router.delete("/clear", response_model=dict)
def clear_basket(db: Session = Depends(get_db)):
    """Clear the current basket"""
    basket = db.query(Basket).filter(Basket.completed == False).first()
    if basket:
        # Delete all items in the basket
        db.query(BasketItem).filter(BasketItem.basket_id == basket.id).delete()
        db.commit()
    
    return {"message": "Basket cleared"}