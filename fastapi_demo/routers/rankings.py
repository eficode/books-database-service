from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Ranking, Book
from ..dtos import RankingCreate, RankingInfo

router = APIRouter(
    prefix="/rankings",
    tags=["rankings"]
)

@router.get("/", response_model=List[RankingInfo],
    summary="Get all rankings",
    description="This endpoint retrieves all ranked books for the logged-in user",
    response_description="A list of all ranked books")
def read_rankings(db: Session = Depends(get_db)):
    rankings = db.query(Ranking).all()
    if not rankings:
        raise HTTPException(status_code=404, detail="No books are ranked")
    result = []
    for ranking in rankings:
        book = db.query(Book).filter(Book.id == ranking.book_id).first()
        result.append(RankingInfo(book_id=book.id, title=book.title, author=book.author, pages=book.pages, rank=ranking.rank))
    return result

@router.post("/", response_model=RankingInfo,
    summary="Rank a book",
    description="This endpoint adds a book to the rankings or updates its rank",
    response_description="The ranked book's information")
def create_ranking(ranking: RankingCreate = Body(...), db: Session = Depends(get_db)):
    if ranking.rank < 1 or ranking.rank > 5:
        raise HTTPException(status_code=400, detail="Invalid ranking")
    book = db.query(Book).filter(Book.id == ranking.book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    db_ranking = db.query(Ranking).filter(Ranking.book_id == ranking.book_id).first()
    if db_ranking:
        db_ranking.rank = ranking.rank
    else:
        db_ranking = Ranking(user_id=1, book_id=ranking.book_id, rank=ranking.rank) # Assuming user_id is 1 for simplicity
        db.add(db_ranking)
    db.commit()
    db.refresh(db_ranking)
    return RankingInfo(book_id=book.id, title=book.title, author=book.author, pages=book.pages, rank=db_ranking.rank)

@router.put("/{book_id}", response_model=RankingInfo,
    summary="Update book ranking",
    description="This endpoint updates the rank of a book in the rankings",
    response_description="The updated ranking's information")
def update_ranking(book_id: int, ranking: RankingCreate = Body(...), db: Session = Depends(get_db)):
    if ranking.rank < 1 or ranking.rank > 5:
        raise HTTPException(status_code=400, detail="Invalid ranking")
    db_ranking = db.query(Ranking).filter(Ranking.book_id == book_id).first()
    if not db_ranking:
        raise HTTPException(status_code=404, detail="Book not ranked")
    db_ranking.rank = ranking.rank
    db.commit()
    db.refresh(db_ranking)
    book = db.query(Book).filter(Book.id == book_id).first()
    return RankingInfo(book_id=book.id, title=book.title, author=book.author, pages=book.pages, rank=db_ranking.rank)

@router.delete("/{book_id}",
    summary="Remove book from rankings",
    description="This endpoint removes a book from the rankings",
    response_description="Confirmation message")
def delete_ranking(book_id: int, db: Session = Depends(get_db)):
    db_ranking = db.query(Ranking).filter(Ranking.book_id == book_id).first()
    if not db_ranking:
        raise HTTPException(status_code=404, detail="Book not ranked")
    db.delete(db_ranking)
    db.commit()
    return {"detail": "Book removed from rankings"}