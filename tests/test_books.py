from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

# Existing tests...

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

# New tests for delete_all_test_books endpoint

def test_delete_all_test_books_unauthorized(mock_db_session):
    response = client.delete("/books/test")
    assert response.status_code == 403
    assert response.json().get("detail") == "Not authorized to delete test books"


def test_delete_all_test_books_system_error(mock_db_session):
    with patch("fastapi_demo.routers.books.db.query", side_effect=Exception("System error")):
        response = client.delete("/books/test")
        assert response.status_code == 500
        assert response.json().get("detail") == "An error occurred while deleting test books"


def test_delete_all_test_books_success(mock_db_session):
    response = client.delete("/books/test")
    assert response.status_code == 200
    assert response.json().get("detail") == "All test books have been deleted"


def test_delete_all_test_books_network_failure(mock_db_session):
    with patch("fastapi_demo.routers.books.db.query", side_effect=Exception("Network failure")):
        response = client.delete("/books/test")
        assert response.status_code == 500
        assert response.json().get("detail") == "An error occurred while deleting test books"


def test_delete_all_test_books_without_confirmation(mock_db_session):
    response = client.delete("/books/test")
    assert response.status_code == 400
    assert response.json().get("detail") == "Deletion not confirmed"