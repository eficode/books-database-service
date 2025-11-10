from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, FavoriteBook
from fastapi import HTTPException

client = TestClient(app)

# Mock database session
from unittest.mock import MagicMock
mock_db_session = MagicMock()

# Test cases
def test_get_favorite_books_no_favorites(monkeypatch):
    def mock_get_db():
        return mock_db_session
    monkeypatch.setattr("fastapi_demo.routers.favorites.get_db", mock_get_db)
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/users/1/favorites")
    assert response.status_code == 404
    assert response.json().get("detail") == "There are no favorite books in your list"

def test_add_favorite_book_already_in_favorites(monkeypatch):
    def mock_get_db():
        return mock_db_session
    monkeypatch.setattr("fastapi_demo.routers.favorites.get_db", mock_get_db)
    mock_db_session.query.return_value.filter.return_value.first.return_value = FavoriteBook(user_id=1, book_id=1)
    response = client.post("/users/1/favorites", json={"book_id": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "The book is already in your favorites"

def test_remove_favorite_book_not_in_favorites(monkeypatch):
    def mock_get_db():
        return mock_db_session
    monkeypatch.setattr("fastapi_demo.routers.favorites.get_db", mock_get_db)
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/users/1/favorites/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "The book is not in your favorites"