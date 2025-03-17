from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from .database import Base, engine
from .routers.books import router as books
from .routers.comments import router as comments
from .routers.book_details import router as book_details

app = FastAPI(
    title="Books Library API",
    description="A simple API for managing books",
    version="1.0.0"
)

# Create tables
Base.metadata.create_all(bind=engine)

# Add routers
app.include_router(comments)
app.include_router(books)
app.include_router(book_details)

# Mount static files
app.mount("/static", StaticFiles(directory="fastapi_demo/static"), name="static")

# Serve index.html at root
@app.get("/", include_in_schema=False)
async def root():
    return FileResponse("fastapi_demo/static/index.html")
