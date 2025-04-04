from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi.responses import JSONResponse, FileResponse
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
import os
from ..database import get_db
from ..models import Book

router = APIRouter()

@router.get("/sales/quarterly")
def get_quarterly_sales(db: Session = Depends(get_db)):
    # Logic to calculate the number of books sold in the last quarter
    total_books_sold = db.query(Book).count() # Simplified for example
    if total_books_sold == 0:
        return JSONResponse(status_code=200, content={"message": "No sales data available for the last quarter."})
    quarter = "Q3 2023" # Example, calculate dynamically
    return {"total_books_sold": total_books_sold, "quarter": quarter}

@router.post("/sales/export")
def export_quarterly_sales(db: Session = Depends(get_db)):
    try:
        # Logic to fetch and export sales data
        total_books_sold = db.query(Book).count() # Simplified for example
        quarter = "Q3 2023" # Example, calculate dynamically
        # Create PDF
        file_path = "/tmp/quarterly_sales_report.pdf"
        c = canvas.Canvas(file_path, pagesize=letter)
        c.drawString(100, 750, f"Quarterly Sales Report: {quarter}")
        c.drawString(100, 730, f"Total Books Sold: {total_books_sold}")
        c.save()
        return FileResponse(file_path, media_type='application/pdf', filename='quarterly_sales_report.pdf')
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": "Export failed"})