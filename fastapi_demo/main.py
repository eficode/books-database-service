from fastapi import FastAPI, HTTPException, Depends, Body
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from .database import get_db
from .dtos import BookInfo, BookCreate
from .models import Book
from typing import List
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from .database import Base, engine
from .routers.books import router as books

app = FastAPI(
    title="Books Library API",
    description="A simple API for managing books",
    version="1.0.0"
)

# Create tables
Base.metadata.create_all(bind=engine)

# Add routers
app.include_router(books)

@app.post("/books/", response_model=BookInfo)
def create_book(book: BookCreate = Body(...), db: Session = Depends(get_db)):
    """
    Create a new book entry in the database.

    Args:
        book (BookCreate): The book details to be created.
        db (Session): The database session.

    Returns:
        BookInfo: The created book's information.
    """
    db_book = Book(**book.dict())
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)

@app.get("/books/year-old", response_model=List[BookInfo])
def get_books_year_old(db: Session = Depends(get_db)):
    """
    Retrieve books that are exactly one year old.

    Args:
        db (Session): The database session.

    Returns:
        List[BookInfo]: A list of books that are a year old.

    Raises:
        HTTPException: If no books are found that are a year old.
    """
    one_year_ago = datetime.now() - timedelta(days=365)
    books = db.query(Book).filter(Book.published_date == one_year_ago.date()).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books found that are a year old")
    return [BookInfo(**book.__dict__) for book in books]
app.mount("/static", StaticFiles(directory="fastapi_demo/static"), name="static")

# Serve index.html at root
@app.get("/", include_in_schema=False)
async def root():
    return FileResponse("fastapi_demo/static/index.html")
