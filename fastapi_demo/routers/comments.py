from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Comment
from ..dtos import CommentCreate, CommentInfo

router = APIRouter(
    prefix="/books/{book_id}/comments",
    tags=["comments"]
)

@router.post("/", response_model=CommentInfo, summary="Add a comment to a book")
def add_comment(book_id: int, comment: CommentCreate, db: Session = Depends(get_db)):
    raise HTTPException(status_code=400, detail="Comments are currently disabled")

@router.get("/", response_model=List[CommentInfo], summary="View comments on a book")
def view_comments(book_id: int, db: Session = Depends(get_db)):
    raise HTTPException(status_code=400, detail="Comments are currently disabled")

@router.put("/{comment_id}", response_model=CommentInfo, summary="Edit a comment on a book")
def edit_comment(book_id: int, comment_id: int, comment: CommentCreate, db: Session = Depends(get_db)):
    raise HTTPException(status_code=400, detail="Comments are currently disabled")

@router.delete("/{comment_id}", summary="Delete a comment on a book")
def delete_comment(book_id: int, comment_id: int, db: Session = Depends(get_db)):
    raise HTTPException(status_code=400, detail="Comments are currently disabled")