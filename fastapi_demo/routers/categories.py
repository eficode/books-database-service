from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Category, Book
from ..dtos import CategoryCreate, CategoryInfo, BookInfo

router = APIRouter(
    prefix="/categories",
    tags=["categories"]
)

@router.post("/", response_model=CategoryInfo, status_code=201)
def create_category(category: CategoryCreate, db: Session = Depends(get_db)):
    if not category.name.strip():
        raise HTTPException(status_code=400, detail="Category name cannot be empty")
    db_category = Category(name=category.name)
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return CategoryInfo(id=db_category.id, name=db_category.name)

@router.get("/", response_model=List[CategoryInfo])
def list_categories(db: Session = Depends(get_db)):
    categories = db.query(Category).all()
    return [CategoryInfo(id=category.id, name=category.name) for category in categories]

@router.get("/{category_id}/books", response_model=List[BookInfo])
def list_books_by_category(category_id: int, db: Session = Depends(get_db)):
    books = db.query(Book).filter(Book.category_id == category_id).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books available in this category")
    return [BookInfo(id=book.id, title=book.title, author=book.author, pages=book.pages, category_id=book.category_id) for book in books]