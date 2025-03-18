from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from datetime import datetime, timedelta
from unittest.mock import MagicMock

client = TestClient(app)

def test_get_books_year_old_success(mock_db_session):
    # Setup mock data
    one_year_ago = datetime.now() - timedelta(days=365)
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Year Old Book", author="Author A", pages=150, published_date=one_year_ago.date())
    ]

    response = client.get("/books/year-old")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0].get("title") == "Year Old Book"

def test_get_books_year_old_no_books(mock_db_session):
    # Setup mock data
    mock_db_session.query.return_value.filter.return_value.all.return_value = []

    response = client.get("/books/year-old")
    assert response.status_code == 404
    assert response.json().get("detail") == "No books found that are a year old"
