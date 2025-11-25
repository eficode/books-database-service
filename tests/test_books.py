from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
import isbnlib

client = TestClient(app)

@patch('fastapi_demo.routers.books.get_db')
def test_search_book_by_isbn_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    response = client.get("/books/search?isbn=1234567890")
    assert response.status_code == 200
    assert response.json() == {
        "id": 1,
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100
    }

@patch('fastapi_demo.routers.books.get_db')
def test_search_book_by_isbn_not_found(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/search?isbn=1234567890")
    assert response.status_code == 404
    assert response.json() == {"detail": "Book not found"}

@patch('fastapi_demo.routers.books.get_db')
def test_search_book_by_isbn_invalid_format(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    response = client.get("/books/search?isbn=invalid_isbn")
    assert response.status_code == 400
    assert response.json() == {"detail": "Invalid ISBN format"}