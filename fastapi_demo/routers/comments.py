from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Comment
from ..dtos import CommentCreate, CommentInfo

router = APIRouter(
    prefix="/comments",
    tags=["comments"]
)

@router.post("/book/{book_id}/comment", response_model=CommentInfo,
          summary="Add a comment to a book",
          description="This endpoint allows a user to add a comment to a book",
          response_description="The created comment's information")
def add_comment(
    book_id: int,
    comment: CommentCreate = Body(..., description="The details of the comment to be created"),
    db: Session = Depends(get_db)):
    if not comment.content.strip():
        raise HTTPException(status_code=400, detail="Comment cannot be empty")
    db_comment = Comment(book_id=book_id, **comment.dict())
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return CommentInfo(**db_comment.__dict__)

@router.get("/book/{book_id}/comments", response_model=List[CommentInfo],
         summary="Get comments for a book",
         description="This endpoint retrieves all comments for a specific book",
         response_description="A list of comments for the book")
def get_comments_for_book(book_id: int, db: Session = Depends(get_db)):
    comments = db.query(Comment).filter(Comment.book_id == book_id).all()
    return [CommentInfo(**comment.__dict__) for comment in comments]
