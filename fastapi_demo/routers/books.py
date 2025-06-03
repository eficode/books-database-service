from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book
import os

router = APIRouter()

UPLOAD_DIRECTORY = "./uploads/book_covers/"

@router.post("/books/{book_id}/cover")
def upload_book_cover(book_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")

    if file.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(status_code=400, detail="Invalid image file")

    file_location = os.path.join(UPLOAD_DIRECTORY, f"{book_id}.{file.filename.split('.')[-1]}")

    try:
        with open(file_location, "wb") as f:
            f.write(file.file.read())
    except Exception as e:
        raise HTTPException(status_code=400, detail="File is corrupted")

    return {"message": "Book cover image uploaded successfully."}
