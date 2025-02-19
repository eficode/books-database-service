from fastapi import Depends, HTTPException, status
from fastapi_demo.schemas import User

# Mock function to get the current user
# In a real application, this would be replaced with actual authentication logic
def get_current_user() -> User:
    # This is a placeholder implementation
    # Replace with actual logic to retrieve the current user
    return User(id=1, is_test_manager=True)