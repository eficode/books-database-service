from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from unittest.mock import MagicMock

client = TestClient(app)

def test_delete_single_book_success(mock_db_session):
    """
    Test successful deletion of a single book.
    """
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)

    response = client.delete("/books/1")

    assert response.status_code == 200
    assert response.json().get("detail") == "Book deleted"

def test_delete_single_book_not_found(mock_db_session):
    """
    Test deletion of a non-existent book.
    """
    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.delete("/books/1")

    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

def test_bulk_delete_books_success(mock_db_session):
    """
    Test successful bulk deletion of multiple books.
    """
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book 1", author="Test Author 1", pages=100),
        Book(id=2, title="Test Book 2", author="Test Author 2", pages=150)
    ]

    response = client.delete("/books/bulk", data='[1, 2]')

    assert response.status_code == 200
    assert response.json().get("detail") == "Books deleted"

def test_bulk_delete_books_not_found(mock_db_session):
    """
    Test bulk deletion with one or more non-existent books.
    """
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book 1", author="Test Author 1", pages=100)
    ]

    response = client.delete("/books/bulk", data='[1, 2]')

    assert response.status_code == 404
    assert response.json().get("detail") == "One or more books not found"
