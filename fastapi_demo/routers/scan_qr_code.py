from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dtos import BookInfo
import qrcode

router = APIRouter(
    prefix="/scan-qr-code",
    tags=["scan-qr-code"]
)

@router.post("/", response_model=BookInfo, summary="Scan QR code to find book", description="This endpoint scans a QR code and fetches the corresponding book details.", response_description="The scanned book's information")
def scan_qr_code(qr_code: str = Body(..., description="The QR code data to be scanned"), db: Session = Depends(get_db)):
    try:
        # Simulate QR code decoding
        book_id = int(qr_code) # Assuming the QR code contains the book ID
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid QR code")
    try:
        db_book = db.query(Book).filter(Book.id == book_id).first()
        if db_book is None:
            raise HTTPException(status_code=404, detail="Book not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail="Network issue")
    return BookInfo(**db_book.__dict__)
