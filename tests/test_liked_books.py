from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book

client = TestClient(app)

def test_read_liked_books(mock_db_session):
    # Mock liked books
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Liked Book 1", author="Author 1", pages=100, favorite=True),
        Book(id=2, title="Liked Book 2", author="Author 2", pages=150, favorite=True)
    ]

    response = client.get("/books/liked")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]["title"] == "Liked Book 1"
    assert response.json()[1]["title"] == "Liked Book 2"

def test_read_liked_books_empty(mock_db_session):
    # Mock no liked books
    mock_db_session.query.return_value.filter.return_value.all.return_value = []

    response = client.get("/books/liked")
    assert response.status_code == 200
    assert response.json() == []
