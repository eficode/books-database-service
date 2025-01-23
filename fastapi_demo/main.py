from fastapi import FastAPI, WebSocket, Depends
from .database import Base, engine, get_db
from .routers.books import router as books
from .routers.best_sellers import router as best_sellers
from .models import Book
from sqlalchemy.orm import Session
from typing import List

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(books)
app.include_router(best_sellers)

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            await connection.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws/best-sellers/")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.broadcast(data)
    except WebSocketDisconnect:
        manager.disconnect(websocket)
