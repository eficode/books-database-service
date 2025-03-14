from datetime import datetime, timedelta
from fastapi import FastAPI, HTTPException, Depends
from typing import List
from sqlalchemy.orm import Session
from .database import get_db
from .models import Book
from .dtos import BookInfo
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

@app.get("/books/week-old", response_model=List[BookInfo])
def get_week_old_books(db: Session = Depends(get_db)):
    one_week_ago = datetime.now() - timedelta(days=7)
    books = db.query(Book).filter(Book.added_date == one_week_ago.date()).all()
    if not books:
        raise HTTPException(status_code=404, detail="No books found that are a week old")
    return [BookInfo(**book.__dict__) for book in books]
app.mount("/static", StaticFiles(directory="fastapi_demo/static"), name="static")

# Serve index.html at root
@app.get("/", include_in_schema=False)
async def root():
    return FileResponse("fastapi_demo/static/index.html")
