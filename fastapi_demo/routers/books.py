from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from ..database import get_db
from ..models import Book
from ..dependencies import get_current_user, User

router = APIRouter()

@router.delete('/books/test')
def delete_all_test_books(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not current_user.is_test_manager:
        raise HTTPException(status_code=403, detail='Insufficient permissions')
    try:
        db.query(Book).filter(Book.is_test == True).delete()
        db.commit()
        return {'detail': 'All test books have been deleted'}
    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(status_code=500, detail='Database error occurred')