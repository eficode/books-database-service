from fastapi import Depends
from fastapi_users import FastAPIUsers, models, schemas
from fastapi_users.authentication import JWTAuthentication
from fastapi_users.db import SQLAlchemyUserDatabase
from sqlalchemy.ext.asyncio import AsyncSession
from .database import get_db
from .models import UserDB

SECRET = "SECRET"

jwt_authentication = JWTAuthentication(secret=SECRET, lifetime_seconds=3600)

async def get_user_db(session: AsyncSession = Depends(get_db)):
    yield SQLAlchemyUserDatabase(UserDB, session)

fastapi_users = FastAPIUsers(
    get_user_db,
    [jwt_authentication],
    UserDB,
    schemas.UserCreate,
    schemas.UserUpdate,
    schemas.UserDB,
)

get_current_user = fastapi_users.current_user()
