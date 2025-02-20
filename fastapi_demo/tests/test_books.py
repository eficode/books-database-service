from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session(monkeypatch):
    mock_session = MagicMock()
    monkeypatch.setattr("fastapi_demo.database.SessionLocal", lambda: mock_session)
    return mock_session

@pytest.fixture
def mock_current_user(monkeypatch):
    mock_user = MagicMock()
    mock_user.is_test_manager = True
    monkeypatch.setattr("fastapi_demo.dependencies.get_current_user", lambda: mock_user)
    return mock_user

@pytest.fixture
def mock_non_test_manager_user(monkeypatch):
    mock_user = MagicMock()
    mock_user.is_test_manager = False
    monkeypatch.setattr("fastapi_demo.dependencies.get_current_user", lambda: mock_user)
    return mock_user

# Existing tests...

def test_delete_all_test_books_success(mock_db_session, mock_current_user):
    response = client.delete("/books/test")
    assert response.status_code == 200
    assert response.json().get("detail") == "All test books have been removed"


def test_delete_all_test_books_not_authorized(mock_db_session, mock_non_test_manager_user):
    response = client.delete("/books/test")
    assert response.status_code == 403
    assert response.json().get("detail") == "Not authorized"


def test_delete_all_test_books_database_error(mock_db_session, mock_current_user):
    mock_db_session.query.side_effect = Exception("Database error")
    response = client.delete("/books/test")
    assert response.status_code == 500
    assert response.json().get("detail") == "Database error occurred"


def test_delete_all_test_books_network_error(mock_db_session, mock_current_user):
    with patch("fastapi_demo.routers.books.db.query", side_effect=Exception("Network error")):
        response = client.delete("/books/test")
        assert response.status_code == 500
        assert response.json().get("detail") == "Network error occurred"
