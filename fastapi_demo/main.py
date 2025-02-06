from fastapi import FastAPI
from .database import Base, engine
from .routers.books import router as books
from .routers.cart import router as cart

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(books)
app.include_router(cart)
