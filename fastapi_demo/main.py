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

## Assignement: Create rest of the CRUD REST methods for book
# implement testing for it and use best coding conventions and practices