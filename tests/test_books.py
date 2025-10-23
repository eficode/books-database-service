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


def test_search_books_valid_isbn(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    ]
    response = client.get("/books/search?isbn=1234567890")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0].get("title") == "Test Book"
    assert response.json()[0].get("author") == "Test Author"
    assert response.json()[0].get("pages") == 100
    assert response.json()[0].get("isbn") == "1234567890"


def test_search_books_invalid_isbn(mock_db_session):
    response = client.get("/books/search?isbn=")
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid or missing ISBN number."


def test_search_books_no_books_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/books/search?isbn=1234567890")
    assert response.status_code == 404
    assert response.json().get("detail") == "No books found with the given ISBN number."
