from fastapi import Depends, HTTPException, status
from fastapi_demo.database import get_db
from sqlalchemy.orm import Session
from fastapi_demo.models import User

def get_current_user(db: Session = Depends(get_db)):
    # Logic to get the current user from the request context
    # This is a placeholder implementation
    user = db.query(User).filter(User.id == 1).first() # Replace with actual user fetching logic
    if user is None:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return user