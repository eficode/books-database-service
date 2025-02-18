from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
import pytest

client = TestClient(app)

# Mocking the get_current_user function to simulate different user roles
@pytest.fixture
def mock_get_current_user(monkeypatch):
    def mock_user(is_test_manager):
        class User:
            def __init__(self, is_test_manager):
                self.is_test_manager = is_test_manager
                self.id = 1  # Example user ID
        return User(is_test_manager)
    monkeypatch.setattr("fastapi_demo.routers.books.get_current_user", lambda: mock_user(True))

# Mocking the database session
@pytest.fixture
def mock_db_session(monkeypatch):
    mock_session = MagicMock()
    monkeypatch.setattr("fastapi_demo.database.SessionLocal", lambda: mock_session)
    return mock_session

# Test cases for the new endpoint
def test_delete_all_test_books_success(mock_db_session, mock_get_current_user):
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book 1", author="Author 1", pages=100),
        Book(id=2, title="Test Book 2", author="Author 2", pages=200)
    ]
    response = client.delete("/books/test")
    assert response.status_code == 200
    assert response.json().get("detail") == "All test books removed successfully"


def test_delete_all_test_books_no_books(mock_db_session, mock_get_current_user):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.delete("/books/test")
    assert response.status_code == 200
    assert response.json().get("detail") == "No test books found to remove"


def test_delete_all_test_books_unauthorized(mock_db_session, monkeypatch):
    def mock_user(is_test_manager):
        class User:
            def __init__(self, is_test_manager):
                self.is_test_manager = is_test_manager
                self.id = 1  # Example user ID
        return User(False)
    monkeypatch.setattr("fastapi_demo.routers.books.get_current_user", lambda: mock_user(False))
    response = client.delete("/books/test")
    assert response.status_code == 403
    assert response.json().get("detail") == "Not authorized"


def test_delete_all_test_books_system_error(mock_db_session, mock_get_current_user):
    mock_db_session.query.return_value.filter.return_value.all.side_effect = Exception("Database error")
    response = client.delete("/books/test")
    assert response.status_code == 500
    assert response.json().get("detail") == "An error occurred while removing test books"


def test_delete_all_test_books_partial_removal(mock_db_session, mock_get_current_user):
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book 1", author="Author 1", pages=100),
        Book(id=2, title="Test Book 2", author="Author 2", pages=200)
    ]
    def mock_delete(*args, **kwargs):
        raise Exception("Partial removal error")
    mock_db_session.query.return_value.filter.return_value.delete.side_effect = mock_delete
    response = client.delete("/books/test")
    assert response.status_code == 500
    assert response.json().get("detail") == "Partial removal error: An error occurred while removing some test books"
