from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, UserBonus, BookProgress
from fastapi import HTTPException

client = TestClient(app)

# Existing tests...

def test_mark_as_read_unsuccessful(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = BookProgress(user_id=1, book_id=1, progress=50)
    response = client.post("/books/1/mark_as_read", json={"user_id": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "User has not marked the book as read"

def test_update_progress_unsuccessful(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put("/books/1/update_progress", json={"user_id": 1, "progress": 50})
    assert response.status_code == 400
    assert response.json().get("detail") == "User has not updated their reading progress"

def test_update_progress_successful(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = BookProgress(user_id=1, book_id=1, progress=50)
    response = client.put("/books/1/update_progress", json={"user_id": 1, "progress": 75})
    assert response.status_code == 200
    assert response.json().get("message") == "Reading progress updated"
    assert response.json().get("bonus_points") == 0
