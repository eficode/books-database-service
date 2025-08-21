from fastapi import FastAPI, HTTPException, Depends
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from .database import Base, engine
from .routers.books import router as books
from .models import Book
from .schemas import BookInfo
from .dependencies import get_db

app = FastAPI(
    title="Books Library API",
    description="A simple API for managing books",
    version="1.0.0"
)

# Create tables
Base.metadata.create_all(bind=engine)

# Add routers
app.include_router(books)

# Mount static files
app.mount("/static", StaticFiles(directory="fastapi_demo/static"), name="static")

# Serve index.html at root
@app.get("/", include_in_schema=False)
async def root():
    return FileResponse("fastapi_demo/static/index.html")

@app.get("/books/genre/{genre}", response_model=List[BookInfo])
def list_books_by_genre(genre: str, db: Session = Depends(get_db)):
    try:
        books = db.query(Book).filter(Book.genre == genre).all()
        if not books:
            raise HTTPException(status_code=404, detail="No books found for the selected genre")
        return [BookInfo(**book.__dict__) for book in books]
    except Exception:
        raise HTTPException(status_code=500, detail="There was a problem fetching books")
