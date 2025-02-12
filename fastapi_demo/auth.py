from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from .models import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme)):
    # Logic to decode token and get user
    user = decode_token(token)
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid authentication credentials")
    return user

async def manager_required(user: User = Depends(get_current_user)):
    if user.role != 'manager':
        raise HTTPException(status_code=403, detail="You do not have the necessary permissions to perform this action.")
    return user
