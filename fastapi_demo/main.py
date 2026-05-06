from fastapi import FastAPI, Depends, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from .database import Base, engine, get_db
from .models import Book
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

# Mount static files
app.mount("/static", StaticFiles(directory="fastapi_demo/static"), name="static")

# Serve index.html at root
@app.get("/", include_in_schema=False)
async def root():
    return FileResponse("fastapi_demo/static/index.html")

@app.get("/books/pricing")
def get_book_pricing(db: Session = Depends(get_db)):
    try:
        books = db.query(Book).all()
        if not books:
            return {"message": "No pricing information available"}
        return {"books": [{"id": book.id, "title": book.title, "price": book.price} for book in books]}
    except Exception as e:
        if "No internet connection" in str(e):
            raise HTTPException(status_code=500, detail="The webpage cannot be loaded")
        if "Server is down" in str(e):
            raise HTTPException(status_code=500, detail="The server is unavailable")
        raise HTTPException(status_code=500, detail="An unexpected error occurred")
