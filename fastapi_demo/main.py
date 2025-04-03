from fastapi import FastAPI, Depends, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from .database import Base, engine, get_db
from .models import Product
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

@app.post("/order-immediately/{product_id}")
def order_immediately(product_id: int, db: Session = Depends(get_db)):
    # Validate product_id
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Add product to cart (assuming a function add_to_cart exists)
    try:
        add_to_cart(product_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to add product to cart")

    # Redirect to checkout page
    return {
        "message": "Product added to cart and redirected to checkout",
        "checkout_url": "https://example.com/checkout"
    }
