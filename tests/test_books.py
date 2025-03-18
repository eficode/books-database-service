# FILEPATH: /Users/alexjantunen/dev/fast-api-demo/test_main.py
from unittest.mock import MagicMock
from fastapi_demo.dtos import BookInfo
from fastapi_demo.models import Book
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book

from datetime import datetime, timedelta

client = TestClient(app)

def test_create_book(mock_db_session):
    """
    Test the creation of a new book.

    Args:
        mock_db_session: The mocked database session.

    Asserts:
        The response status code is 200.
        The response contains the correct book details.
    """
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100,
        "category": "Fiction",
        "favorite": False,
        "published_date": "2024-03-18"
    })

    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

def test_read_book_success(mock_db_session):
    """
    Test reading a book successfully.

    Args:
        mock_db_session: The mocked database session.

    Asserts:
        The response status code is 200.
        The response contains the correct book details.
    """
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.get("/books/1")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

def test_read_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/1")
    assert response.status_code == 500
    assert response.json().get("detail") == "Book not found"


def test_update_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", pages=100, published_date=datetime.now().date())

    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200,
        "category": "Fiction",
        "favorite": False,
        "published_date": "2024-03-18"
    })

    assert response.status_code == 200
    assert response.json().get("title") == "New Title"
    assert response.json().get("author") == "New Author"
    assert response.json().get("pages") == 200

def test_update_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200
    })

    assert response.status_code == 500
    assert response.json().get("detail") == "Book not found"

def test_get_books_year_old_success(mock_db_session):
    one_year_ago = datetime.now() - timedelta(days=365)
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Year Old Book", author="Author", pages=100, published_date=one_year_ago.date())
    ]
    response = client.get("/books/year-old")
    assert response.status_code == 200, "Expected status code 200"
    assert len(response.json()) == 1, "Expected one book in response"
    assert response.json()[0]["title"] == "Year Old Book", "Expected title 'Year Old Book'"

def test_get_books_year_old_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/books/year-old")
    assert response.status_code == 404, "Expected status code 404"
    assert response.json().get("detail") == "No books found that are a year old", "Expected detail message for no books found"
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)

    response = client.delete("/books/1")

    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"

    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.delete("/books/1")

    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"
