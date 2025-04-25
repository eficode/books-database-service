from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, FavouriteBooks
from unittest.mock import MagicMock

client = TestClient(app)

# Mock database session
mock_db_session = MagicMock()

# Test for retrieving favourite books
def test_get_favourite_books():
    mock_db_session.query.return_value.join.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book 1", author="Author 1", pages=100),
        Book(id=2, title="Test Book 2", author="Author 2", pages=200)
    ]
    response = client.get("/users/1/favourites")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]["title"] == "Test Book 1"
    assert response.json()[1]["title"] == "Test Book 2"

# Test for purchasing a favourite book
def test_purchase_favourite_book():
    response = client.post("/users/1/favourites/1/purchase")
    assert response.status_code == 200
    assert "purchase_url" in response.json()