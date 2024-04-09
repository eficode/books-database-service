from fastapi import FastAPI, Depends, HTTPException
from .database import get_db, engine, Base
from .models import Book, BookCreate, BookInfo
from sqlalchemy.orm import Session

app = FastAPI()

Base.metadata.create_all(bind=engine)

@app.post("/books/", response_model=BookInfo)
def create_book(book: BookCreate, db: Session = Depends(get_db)):
    db_book = Book(**book.model_dump())
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)

## Assignement: Create rest of the CRUD methods as follows for managing book entities
# This project has already implemented creation of book and unit test for it.
# 
# 1. Create book read method with unit testing, use best coding conventions and practices.
# 2. Create book update method with unit testing, use best coding conventions and practices.
# 3. Create book delete method with unit testing, use best coding conventions and practices.
