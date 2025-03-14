from datetime import datetime, timedelta
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session(mocker):
    """Fixture to mock the database session."""
    return mocker.patch('fastapi_demo.database.SessionLocal')

def test_get_week_old_books_success(mock_db_session):
    """Test retrieving books that are exactly a week old."""
    one_week_ago = datetime.now() - timedelta(days=7)
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Week Old Book", author="Author", pages=123, added_date=one_week_ago.date())
    ]

    response = client.get("/books/week-old")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0].get("title") == "Week Old Book"
    assert response.json()[0].get("author") == "Author"
    assert response.json()[0].get("pages") == 123
    assert response.json()[0].get("added_date") == one_week_ago.date().isoformat()

def test_get_week_old_books_not_found(mock_db_session):
    """Test retrieving books when none are a week old."""
    mock_db_session.query.return_value.filter.return_value.all.return_value = []

    response = client.get("/books/week-old")
    assert response.status_code == 404
    assert response.json().get("detail") == "No books found that are a week old"
