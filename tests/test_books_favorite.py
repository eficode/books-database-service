from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book

client = TestClient(app)

def test_toggle_favorite_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, favorite=False)

    response = client.patch("/books/1/favorite", json={"favorite": True})

    assert response.status_code == 200
    assert response.json().get("favorite") is True

def test_toggle_favorite_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.patch("/books/1/favorite", json={"favorite": True})

    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"
