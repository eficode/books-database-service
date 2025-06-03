from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book
import shutil
import os

router = APIRouter()

@router.post("/books/{book_id}/cover")
def upload_cover(book_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")

    # Validate file type
    if file.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(status_code=400, detail="The file type is not supported")

    # Validate file size
    if file.spool_max_size > 5 * 1024 * 1024:  # 5 MB limit
        raise HTTPException(status_code=400, detail="The file size is too large")

    # Save the file
    file_location = f"covers/{book_id}_{file.filename}"
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Update the book record with the new cover URL
    book.cover_url = file_location
    db.commit()
    db.refresh(book)

    return {"message": "Cover image uploaded successfully", "book_id": book.id, "cover_url": book.cover_url}
