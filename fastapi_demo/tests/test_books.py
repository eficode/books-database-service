from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

# Existing test cases...

def test_delete_test_books_unauthorized(mock_db_session):
    with patch("fastapi_demo.dependencies.get_current_user", return_value=MagicMock(is_test_manager=False)):
        response = client.delete("/books/test")
        assert response.status_code == 403
        assert response.json().get("detail") == "Not authorized to delete test books"

def test_delete_test_books_system_error(mock_db_session):
    with patch("fastapi_demo.dependencies.get_current_user", return_value=MagicMock(is_test_manager=True)):
        mock_db_session.query.side_effect = Exception("System error")
        response = client.delete("/books/test")
        assert response.status_code == 500
        assert response.json().get("detail") == "System error occurred while deleting test books"

def test_delete_test_books_partial_deletion(mock_db_session):
    with patch("fastapi_demo.dependencies.get_current_user", return_value=MagicMock(is_test_manager=True)):
        mock_db_session.query.return_value.filter.return_value.all.return_value = [Book(id=1, title="Test Book 1", author="Test Author", pages=100, is_test=True), Book(id=2, title="Test Book 2", author="Test Author", pages=100, is_test=True)]
        mock_db_session.query.return_value.filter.return_value.delete.side_effect = Exception("Partial deletion error")
        response = client.delete("/books/test")
        assert response.status_code == 500
        assert response.json().get("detail") == "System error occurred while deleting test books"
