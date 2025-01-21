from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from .database import get_db
from .models import User
from sqlalchemy.orm import Session

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    user = db.query(User).filter(User.token == token).first()
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid authentication credentials")
    return user
