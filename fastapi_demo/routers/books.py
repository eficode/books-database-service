from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi_demo.dependencies import get_db, get_current_user
from fastapi_demo.models import Book

router = APIRouter()


@router.delete("/books/test")
def delete_all_test_books(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not current_user.is_test_manager:
        raise HTTPException(status_code=403, detail="Not authorized to delete test books")
    try:
        db.query(Book).filter(Book.is_test == True).delete()
        db.commit()
    except Exception as e:
        raise HTTPException(status_code=500, detail="An error occurred while deleting test books")
    return {"detail": "All test books have been deleted"}