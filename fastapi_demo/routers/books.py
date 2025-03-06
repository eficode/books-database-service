from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book
from fastapi_demo.dtos import BookInfo
from typing import Optional, List
from fastapi.responses import JSONResponse, StreamingResponse
import csv
from io import StringIO
from datetime import datetime

router = APIRouter()

@router.get("/top-sold-books/", response_model=List[BookInfo])
def get_top_sold_books(start_date: Optional[str] = None, end_date: Optional[str] = None, db: Session = Depends(get_db)):
    try:
        if start_date:
            try:
                datetime.strptime(start_date, "%Y-%m-%d")
            except ValueError:
                raise HTTPException(status_code=422, detail="Invalid date range")
        if end_date:
            try:
                datetime.strptime(end_date, "%Y-%m-%d")
            except ValueError:
                raise HTTPException(status_code=422, detail="Invalid date range")
        query = db.query(Book).filter(Book.industry == 'mining')
        if start_date:
            query = query.filter(Book.sale_date >= start_date)
        if end_date:
            query = query.filter(Book.sale_date <= end_date)
        books = query.order_by(Book.sales_volume.desc()).all()
        return books
    except Exception as e:
        raise HTTPException(status_code=500, detail="Data could not be loaded due to a network issue")

@router.get("/top-sold-books/export/")
def export_top_sold_books(start_date: Optional[str] = None, end_date: Optional[str] = None, db: Session = Depends(get_db)):
    try:
        if start_date:
            try:
                datetime.strptime(start_date, "%Y-%m-%d")
            except ValueError:
                raise HTTPException(status_code=422, detail="Invalid date range")
        if end_date:
            try:
                datetime.strptime(end_date, "%Y-%m-%d")
            except ValueError:
                raise HTTPException(status_code=422, detail="Invalid date range")
        query = db.query(Book).filter(Book.industry == 'mining')
        if start_date:
            query = query.filter(Book.sale_date >= start_date)
        if end_date:
            query = query.filter(Book.sale_date <= end_date)
        books = query.order_by(Book.sales_volume.desc()).all()
        output = StringIO()
        writer = csv.writer(output)
        writer.writerow(["id", "title", "author", "sales_volume"])
        for book in books:
            writer.writerow([book.id, book.title, book.author, book.sales_volume])
        output.seek(0)
        return StreamingResponse(output, media_type="text/csv", headers={"Content-Disposition": "attachment; filename=top_sold_books.csv"})
    except Exception as e:
        raise HTTPException(status_code=500, detail="Export failed due to a server error")