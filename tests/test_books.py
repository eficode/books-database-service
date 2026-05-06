from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)


def test_create_book(mock_db_session):
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100,
        "isbn": "1234567890"
    })
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100
    assert response.json().get("isbn") == "1234567890"


def test_read_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    response = client.get("/books/1")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100
    assert response.json().get("isbn") == "1234567890"


def test_read_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"


def test_update_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", pages=100, isbn="1234567890")
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200,
        "isbn": "1234567890"
    })
    assert response.status_code == 200
    assert response.json().get("title") == "New Title"
    assert response.json().get("author") == "New Author"
    assert response.json().get("pages") == 200
    assert response.json().get("isbn") == "1234567890"


def test_update_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200,
        "isbn": "1234567890"
    })
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"


def test_delete_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    response = client.delete("/books/1")
    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"


def test_delete_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"


def test_read_books_error_fetching_prices(mock_db_session):
    mock_db_session.query.return_value.all.return_value = [
        Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    ]
    with patch('fastapi_demo.utils.fetch_amazon_price', return_value=None):
        response = client.get("/books/")
        assert response.status_code == 500
        assert response.json().get("detail") == "Error fetching prices from Amazon.com"


def test_read_books_price_update_in_progress(mock_db_session):
    mock_db_session.query.return_value.all.return_value = [
        Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    ]
    with patch('fastapi_demo.utils.fetch_amazon_price', side_effect=Exception("Price update in progress")):
        response = client.get("/books/")
        assert response.status_code == 503
        assert response.json().get("detail") == "Price update is in progress"