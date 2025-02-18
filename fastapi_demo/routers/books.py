from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book
from fastapi_demo.dependencies import get_current_user

router = APIRouter()

@router.delete("/books/test", status_code=status.HTTP_200_OK)
def delete_test_books(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not current_user.is_test_manager:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete test books")
    try:
        test_books = db.query(Book).filter(Book.is_test == True).all()
        if not test_books:
            return {"detail": "No test books found to delete."}
        db.query(Book).filter(Book.is_test == True).delete()
        db.commit()
        return {"detail": "All test books have been successfully removed."}
    except Exception as e:
        db.rollback()
        if "Partial deletion error" in str(e):
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="System error occurred while deleting test books")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="System error occurred while deleting test books")
