from sqlalchemy import Column, DateTime
from ..database import engine
from sqlalchemy.orm import sessionmaker

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def upgrade():
    with engine.connect() as connection:
        connection.execute('ALTER TABLE books ADD COLUMN release_date DATETIME')
