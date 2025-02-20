from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from fastapi_demo.database import get_db
from fastapi_demo.models import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

class User:
    def __init__(self, is_test_manager: bool):
        self.is_test_manager = is_test_manager

# Mock function to get the current user
async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    # In a real application, you would verify the token and fetch the user from the database
    # Here we just return a mock user for simplicity
    return User(is_test_manager=True)
