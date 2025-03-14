from datetime import datetime, timedelta
from unittest.mock import MagicMock
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book

client = TestClient(app)

def test_get_week_old_books_success(mock_db_session):
    # Prepare mock data
    one_week_ago = datetime.now() - timedelta(days=7)
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Week Old Book", author="Author", pages=123, added_date=one_week_ago.date())
    ]

    response = client.get("/books/week-old")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["title"] == "Week Old Book"

def test_get_week_old_books_not_found(mock_db_session):
    # No books found
    mock_db_session.query.return_value.filter.return_value.all.return_value = []

    response = client.get("/books/week-old")
    assert response.status_code == 404
    assert response.json().get("detail") == "No books found that are a week old"
