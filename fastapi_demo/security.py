from fastapi.security import OAuth2PasswordBearer
from fastapi import Security, Depends, HTTPException
from .models import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def get_current_user(token: str = Depends(oauth2_scheme)):
    # Implement token validation logic
    pass

def get_current_active_sales_manager(current_user: User = Security(get_current_user, scopes=["sales_manager"])):
    if not current_user.is_sales_manager:
        raise HTTPException(status_code=403, detail="Not authorized")
    return current_user
