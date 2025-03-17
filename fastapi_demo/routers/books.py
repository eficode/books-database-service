from fastapi import APIRouter, Depends, HTTPException, Body, Path
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Book, Comment
from ..dtos import BookCreate, BookInfo, BookFavorite, CommentCreate, CommentInfo

router = APIRouter(
    prefix="/books",
    tags=["books"]
)

@router.get("/", response_model=List[BookInfo],
         summary="Get all books",
         description="This endpoint retrieves all books from the database",
         response_description="A list of all books")
def read_books(db: Session = Depends(get_db)):
    books = db.query(Book).all()
    return [BookInfo(**book.__dict__) for book in books]


@router.post("/", response_model=BookInfo, 
          summary="Create a new book", 
          description="This endpoint creates a new book with the provided details and returns the book information",
          response_description="The created book's information")
def create_book(
    book: BookCreate = Body(..., description="The details of the book to be created", examples={"title": "Example Book", "author": "John Doe", "year": 2021}),
    db: Session = Depends(get_db)):
    db_book = Book(**book.model_dump())
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)


@router.get("/{book_id}", 
         response_model=BookInfo, 
         summary="Read a book", 
         description="This endpoint retrieves the details of a book with the provided ID",
         response_description="The requested book's information")
def read_book(
    book_id: int = Path(..., description="The ID of the book to be retrieved", examples=1),
    db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return BookInfo(**db_book.__dict__)


@router.put("/{book_id}", response_model=BookInfo,
          summary="Update a book",
          description="This endpoint updates the details of a book with the provided ID",
          response_description="The updated book's information")
def update_book(book_id: int, book: BookCreate, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    for key, value in book.model_dump().items():
        setattr(db_book, key, value)
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)

@router.delete("/{book_id}",
             summary="Delete a book",
             description="This endpoint deletes a book with the provided ID",
             response_description="Confirmation message")
def delete_book(book_id: int, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    db.delete(db_book)
    db.commit()
    return {"message": "Book deleted successfully"}


@router.get("/{book_id}/comments", response_model=List[CommentInfo],
           summary="Get comments for a book",
           description="This endpoint retrieves comments for a specific book",
           response_description="A list of comments for the book")
def get_comments_for_book(book_id: int, db: Session = Depends(get_db)):
    comments = db.query(Comment).filter(Comment.book_id == book_id).limit(1000).all()
    return [CommentInfo(**comment.__dict__) for comment in comments]

@router.post("/{book_id}/comments", response_model=CommentInfo,
           summary="Add a comment to a book",
           description="This endpoint allows a user to add a comment to a book",
           response_description="The created comment's information")
def add_comment(book_id: int, comment: CommentCreate, db: Session = Depends(get_db)):
    if not comment.content.strip():
        raise HTTPException(status_code=400, detail="Comment cannot be empty")
    db_comment = Comment(book_id=book_id, **comment.model_dump())
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return CommentInfo(**db_comment.__dict__)

@router.patch("/{book_id}/favorite", response_model=BookInfo,
           summary="Toggle book favorite status",
           description="This endpoint toggles the favorite status of a book with the provided ID",
           response_description="The updated book's information")
def toggle_favorite(book_id: int, favorite: BookFavorite, db: Session = Depends(get_db)):
    db_book = db.query(Book).filter(Book.id == book_id).first()
    if db_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    
    db_book.favorite = favorite.favorite
    db.commit()
    db.refresh(db_book)
    return BookInfo(**db_book.__dict__)
