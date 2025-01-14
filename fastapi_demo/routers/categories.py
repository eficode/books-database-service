from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Category, Book
from ..dtos import CategoryCreate, CategoryInfo, BookCategoryAssign, BookSearchByCategory

router = APIRouter()

@router.post("/categories/", response_model=CategoryInfo, summary="Create a new category", description="This endpoint creates a new category with the provided details and returns the category information", response_description="The created category's information")
def create_category(category: CategoryCreate = Body(..., description="The details of the category to be created"), db: Session = Depends(get_db)):
    db_category = Category(**category.dict())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return CategoryInfo(**db_category.__dict__)

@router.post("/categories/assign/", response_model=BookCategoryAssign, summary="Assign a book to a category", description="This endpoint assigns a book to a category", response_description="The assignment details")
def assign_book_to_category(assignment: BookCategoryAssign = Body(..., description="The details of the book and category assignment"), db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == assignment.book_id).first()
    db_category = db.query(Category).filter(Category.id == assignment.category_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    if db_category is None:
        raise HTTPException(status_code=404, detail="Category not found")
    db_book.category_id = assignment.category_id
    db.commit()
    db.refresh(db_book)
    return assignment

@router.get("/categories/{category_id}/books", response_model=list[BookInfo], summary="Search books by category", description="This endpoint retrieves books by category", response_description="The list of books under the category")
def search_books_by_category(category_id: int = Path(..., description="The ID of the category to search books for"), db: Session = Depends(get_db)):
    db_category = db.query(Category).filter(Category.id == category_id).first()
    if db_category is None:
        raise HTTPException(status_code=404, detail="Category not found")
    return [BookInfo(**book.__dict__) for book in db_category.books]
