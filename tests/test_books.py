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
        "pages": 100
    })
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100


def test_read_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.get("/books/1")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100


def test_read_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"


def test_update_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", pages=100)
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200
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
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"


def test_delete_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.delete("/books/1")
    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"


def test_delete_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"


def test_get_book_pricing_success(mock_db_session):
    mock_db_session.query.return_value.all.return_value = [
        Book(id=1, title="Test Book", price=19.99),
        Book(id=2, title="Another Book", price=29.99)
    ]
    response = client.get("/books/pricing")
    assert response.status_code == 200
    assert response.json() == {
        "books": [
            {"id": 1, "title": "Test Book", "price": 19.99},
            {"id": 2, "title": "Another Book", "price": 29.99}
        ]
    }


def test_get_book_pricing_no_books(mock_db_session):
    mock_db_session.query.return_value.all.return_value = []
    response = client.get("/books/pricing")
    assert response.status_code == 200
    assert response.json() == {"message": "No pricing information available"}


def test_no_internet_connection():
    with patch("fastapi_demo.main.get_book_pricing", side_effect=Exception("No internet connection")):
        response = client.get("/books/pricing")
        assert response.status_code == 500
        assert response.json() == {"detail": "The webpage cannot be loaded"}


def test_server_down():
    with patch("fastapi_demo.main.get_book_pricing", side_effect=Exception("Server is down")):
        response = client.get("/books/pricing")
        assert response.status_code == 500
        assert response.json() == {"detail": "The server is unavailable"}
