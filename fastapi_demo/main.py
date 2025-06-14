from fastapi import FastAPI, Request, Body
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse
from typing import List, Dict, Any
from .database import Base, engine
from .routers.books import router as books
from .routers.basket import router as basket
from .routers.dashboard import router as dashboard
from .mcp_server import setup_mcp_server

app = FastAPI(
    title="Books Library API",
    description="A simple API for managing books",
    version="1.0.0"
)

# Debug logs storage
browser_logs = []

# Create tables
Base.metadata.create_all(bind=engine)

# Add routers
app.include_router(books)
app.include_router(basket, prefix="/basket", tags=["basket"])
app.include_router(dashboard, prefix="/dashboard", tags=["dashboard"])

# Setup MCP server
setup_mcp_server(app)

# Mount static files
app.mount("/static", StaticFiles(directory="fastapi_demo/static"), name="static")

# Serve index.html at root
@app.get("/", include_in_schema=False)
async def root():
    return FileResponse("fastapi_demo/static/index.html")

# Serve dashboard.html
@app.get("/dashboard", include_in_schema=False)
async def dashboard_page():
    return FileResponse("fastapi_demo/static/dashboard.html")

# Add custom 404 handler for /login
@app.get("/login", include_in_schema=False)
async def login_redirect():
    return FileResponse("fastapi_demo/static/index.html")

# Debug endpoint to log browser console messages
@app.post("/debug/log")
async def debug_log(logs: List[Dict[str, Any]] = Body(...)):
    global browser_logs
    browser_logs.extend(logs)
    print("Received browser logs:", logs)
    return {"status": "ok"}

# Debug endpoint to retrieve logs
@app.get("/debug/logs")
async def get_debug_logs():
    return {"logs": browser_logs}

# Custom exception handler for all not found paths
@app.exception_handler(404)
async def custom_404_handler(request: Request, exc):
    # For debugging
    print(f"404 error: {request.url.path}")
    
    # If it's an API request, return a standard 404 JSON response
    if request.url.path.startswith("/books"):
        return JSONResponse(
            status_code=404,
            content={"detail": "Not found"}
        )
    
    # For other requests that might be frontend routes, serve the index.html
    return FileResponse("fastapi_demo/static/index.html")