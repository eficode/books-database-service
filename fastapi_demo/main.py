from fastapi import FastAPI
from fastapi.middleware.gzip import GZipMiddleware
from .database import Base, engine
from .routers.books import router as books

app = FastAPI()

# Middleware for response compression
app.add_middleware(GZipMiddleware, minimum_size=1000)

Base.metadata.create_all(bind=engine)

app.include_router(books)