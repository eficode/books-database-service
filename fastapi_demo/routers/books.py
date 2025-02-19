from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import Book
from fastapi_demo.dependencies import get_current_user
from fastapi_demo.schemas import User

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
        raise e
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to delete test books")

# Helper function to log the deletion action
def log_deletion_action(user_id: int):
    with open("deletion_log.txt", "a") as log_file:
        log_file.write(f"{datetime.now()} - User {user_id} deleted all test books\n")
