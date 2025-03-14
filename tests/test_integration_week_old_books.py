from datetime import datetime, timedelta
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.database import get_db
from sqlalchemy.orm import Session

client = TestClient(app)

def test_create_and_get_week_old_books(mock_db_session):
    # Create a book with today's date
    response = client.post("/books/", json={
        "title": "Today's Book",
        "author": "Author Today",
        "pages": 150
    })
    assert response.status_code == 200

    # Manually set the added_date to a week ago for testing
    one_week_ago = datetime.now() - timedelta(days=7)
    book_id = response.json().get("id")
    book = mock_db_session.query(Book).filter(Book.id == book_id).first()
    book.added_date = one_week_ago.date()
    mock_db_session.commit()

    # Retrieve books that are a week old
    response = client.get("/books/week-old")
    assert response.status_code == 200
    assert len(response.json()) > 0
    assert response.json()[0].get("title") == "Today's Book"

def test_get_week_old_books_not_found(mock_db_session):
    # Ensure no books are a week old
    mock_db_session.query(Book).delete()
    mock_db_session.commit()

    response = client.get("/books/week-old")
    assert response.status_code == 404
    assert response.json().get("detail") == "No books found that are a week old"
