from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from sqlalchemy.exc import OperationalError
from typing import List
from datetime import datetime, timedelta
from ..database import get_db
from ..models import Book
from ..dtos import BookCreate, BookInfo, BookFavorite

router = APIRouter(
    prefix="/books",
    tags=["books"]
)
@router.get("/year-old", response_model=List[BookInfo],
         summary="Get books that are a year old",
         description="This endpoint retrieves books that were published exactly one year ago",
         response_description="A list of books that are a year old")
def get_books_year_old(db: Session = Depends(get_db)):
    """
    Retrieve books that were published exactly one year ago.
    
    Args:
        db (Session): The database session dependency.

    Returns:
        List[BookInfo]: A list of books that are a year old.

    Raises:
        HTTPException: If no books are found that are a year old.
    """
    one_year_ago = datetime.now() - timedelta(days=365)
    try:
        try:
            books = db.query(Book).filter(Book.published_date == one_year_ago.date()).all()
        except OperationalError:
            raise HTTPException(status_code=500, detail="Database connection error")
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    except OperationalError:
        raise HTTPException(status_code=500, detail="Database connection failed")
    except Exception:
        raise HTTPException(status_code=500, detail="Query failed due to an unexpected error")
    
    if not books:
        raise HTTPException(status_code=404, detail="No books found that are a year old")
    return [BookInfo(**book.__dict__) for book in books]


@router.post("/", response_model=BookInfo, 
          summary="Create a new book", 
          description="This endpoint creates a new book with the provided details and returns the book's information",
          response_description="The created book's information")
def create_book(
    book: BookCreate = Body(..., description="The details of the book to be created", examples={"title": {"summary": "A book title", "value": "Example Book"}}),
    db: Session = Depends(get_db)):
    db_book = Book(**book.dict())
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)


@router.get("/{book_id}", 
         response_model=BookInfo, 
         summary="Read a book", 
         description="This endpoint retrieves the details of a book with the provided ID",
         response_description="The requested book's information")
def read_book(
    book_id: int = Path(..., description="The ID of the book to be retrieved", examples=1),
    db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return BookInfo(**db_book.__dict__)


@router.put("/{book_id}", response_model=BookInfo,
          summary="Update a book",
          description="This endpoint updates the details of a book with the provided ID",
          response_description="The updated book's information")
def update_book(book_id: int, book: BookCreate, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    for key, value in book.model_dump().items():
        setattr(db_book, key, value)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)

@router.delete("/{book_id}",
             summary="Delete a book",
             description="This endpoint deletes a book with the provided ID",
             response_description="Confirmation message")
def delete_book(book_id: int, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    db.delete(db_book)
    db.commit()
    return {"message": "Book deleted successfully"}



@router.patch("/{book_id}/favorite", response_model=BookInfo,
           summary="Toggle book favorite status",
           description="This endpoint toggles the favorite status of a book with the provided ID",
           response_description="The updated book's information")
def toggle_favorite(book_id: int, favorite: BookFavorite, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    
    db_book.favorite = favorite.favorite
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)
