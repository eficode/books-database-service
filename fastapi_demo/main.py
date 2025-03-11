from fastapi import FastAPI, Depends, HTTPException
from .database import Base, engine
from .routers.books import router as books
from .routers.demo_mode import router as demo_mode

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(books)
app.include_router(demo_mode)
