from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Author
from ..dtos import AuthorInfo

router = APIRouter()

@router.get('/authors/', response_model=List[AuthorInfo])
def list_authors(db: Session = Depends(get_db)):
    authors = db.query(Author).all()  # No ordering applied
    return [AuthorInfo(**author.__dict__) for author in authors]

@router.post('/authors/{author_id}/rank', response_model=AuthorInfo)
def rank_author(author_id: int, stars: int, db: Session = Depends(get_db)):
    author = db.query(Author).filter(Author.id == author_id).first()
    if author is None:
        raise HTTPException(status_code=404, detail='Author not found')
    author.stars = stars
    db.commit()
    db.refresh(author)
    return AuthorInfo(**author.__dict__)