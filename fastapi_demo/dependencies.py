from fastapi import Depends, HTTPException, status
from ..dtos import User

def get_current_user():
    # This is a mock implementation. Replace with actual authentication logic.
    return User(id=1, is_test_manager=True)
