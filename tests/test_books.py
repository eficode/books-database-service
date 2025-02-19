from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
import pytest

client = TestClient(app)

@pytest.fixture
@patch('fastapi_demo.dependencies.get_current_user')
def mock_current_user(mock_get_current_user):
    mock_get_current_user.return_value = User(id=1, is_test_manager=True)
    yield mock_get_current_user

@pytest.fixture
@patch('fastapi_demo.database.get_db')
def mock_db_session(mock_get_db):
    mock_session = MagicMock()
    mock_get_db.return_value = mock_session
    yield mock_session

# Test for unauthorized user
@patch('fastapi_demo.dependencies.get_current_user')
def test_delete_all_test_books_unauthorized(mock_get_current_user, mock_db_session):
    mock_get_current_user.return_value = User(id=1, is_test_manager=False)
    response = client.delete("/books/test")
    assert response.status_code == 401
    assert response.json().get("detail") == "Not authorized"

# Test for system error
@patch('fastapi_demo.dependencies.get_current_user')
def test_delete_all_test_books_system_error(mock_get_current_user, mock_db_session):
    mock_get_current_user.return_value = User(id=1, is_test_manager=True)
    mock_db_session.query.side_effect = Exception("System error")
    response = client.delete("/books/test")
    assert response.status_code == 500
    assert response.json().get("detail") == "Failed to delete test books"

# Test for network failure
@patch('fastapi_demo.dependencies.get_current_user')
def test_delete_all_test_books_network_failure(mock_get_current_user, mock_db_session):
    mock_get_current_user.return_value = User(id=1, is_test_manager=True)
    mock_db_session.query.side_effect = HTTPException(status_code=503, detail="Network failure")
    response = client.delete("/books/test")
    assert response.status_code == 503
    assert response.json().get("detail") == "Network failure"
