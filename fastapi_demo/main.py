from fastapi import FastAPI
from .database import Base, engine
from .routers.books import router as books
from .routers.top_selling_books import router as top_selling_books

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(books)
app.include_router(top_selling_books)
