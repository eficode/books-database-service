from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
from .database import get_db
from .models import User

class User:
    def __init__(self, is_test_manager: bool):
        self.is_test_manager = is_test_manager

# Mock function to get the current user
# In a real application, this would fetch the user from the database or token

def get_current_user(db: Session = Depends(get_db)) -> User:
    # Mocked user for demonstration
    return User(is_test_manager=True)
