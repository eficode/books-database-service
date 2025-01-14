from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Category, BookCategory, Book
from ..dtos import CategoryCreate, CategoryInfo, BookCategoryCreate, BookCategoryInfo, BookInfoInCategory

router = APIRouter()

@router.post("/categories/", response_model=CategoryInfo, status_code=201)
def create_category(category: CategoryCreate, db: Session = Depends(get_db)):
    db_category = Category(**category.dict())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return CategoryInfo(**db_category.__dict__)

@router.post("/categories/{category_id}/books/", response_model=BookCategoryInfo)
def assign_book_to_category(category_id: int, book_category: BookCategoryCreate, db: Session = Depends(get_db)):
    db_book_category = BookCategory(category_id=category_id, book_id=book_category.book_id)
    db.add(db_book_category)
    db.commit()
    db.refresh(db_book_category)
    return BookCategoryInfo(**db_book_category.__dict__)

@router.get("/categories/{category_id}/books/", response_model=List[BookInfoInCategory])
def get_books_by_category(category_id: int, db: Session = Depends(get_db)):
    books = db.query(Book).join(BookCategory).filter(BookCategory.category_id == category_id).all()
    return [BookInfoInCategory(**book.__dict__) for book in books]
