from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book
from fastapi_demo.dependencies import get_current_user, User

router = APIRouter()

@router.delete("/books/test")
def delete_all_test_books(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not current_user.is_test_manager:
        raise HTTPException(status_code=403, detail="Not authorized")
    try:
        db.query(Book).filter(Book.is_test == True).delete()
        db.commit()
    except Exception as e:
        if "network" in str(e).lower():
            raise HTTPException(status_code=500, detail="Network error occurred")
        else:
            raise HTTPException(status_code=500, detail="Database error occurred")
    return {"detail": "All test books have been removed"}
