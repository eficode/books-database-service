from fastapi import Depends, HTTPException
from .models import User
from .database import get_db
from sqlalchemy.orm import Session


def get_current_user(db: Session = Depends(get_db)) -> User:
    # Logic to get the current user from the request context
    # This is a placeholder and should be replaced with actual implementation
    user = db.query(User).filter(User.id == 1).first()  # Example user retrieval
    if user is None:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return user