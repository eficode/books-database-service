from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Book
from ..dependencies import get_current_user
from ..dtos import User
import logging

router = APIRouter()

@router.delete("/books/test")
def delete_all_test_books(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not current_user.is_test_manager:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authorized")
    try:
        db.query(Book).filter(Book.title.like('%test%')).delete(synchronize_session=False)
        db.commit()
        log_deletion_action(current_user.id)
        return {"detail": "All test books deleted"}
    except HTTPException as e:
        db.rollback()
        if e.status_code == 503:
            raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Network failure")
        raise e
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to delete test books")

# Helper function to log the deletion action
def log_deletion_action(user_id: int):
    logging.basicConfig(filename="deletion_log.txt", level=logging.INFO)
    logging.info(f"{datetime.now()} - User {user_id} deleted all test books")
