from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, Favorite
from fastapi_demo.dependencies import get_current_user
from unittest.mock import MagicMock

client = TestClient(app)

# Mock current user dependency
mock_current_user = MagicMock()
mock_current_user.id = 1
app.dependency_overrides[get_current_user] = lambda: mock_current_user

# Mock database session
mock_db_session = MagicMock()
app.dependency_overrides[get_db] = lambda: mock_db_session


def test_get_favorites():
    mock_db_session.query.return_value.join.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book", author="Test Author", pages=100)
    ]
    response = client.get("/favorites/")
    assert response.status_code == 200
    assert response.json() == [
        {
            "id": 1,
            "title": "Test Book",
            "author": "Test Author",
            "pages": 100
        }
    ]


def test_add_to_favorites():
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.post("/favorites/1")
    assert response.status_code == 201
    assert response.json() == {"detail": "Book added to favorites"}


def test_add_to_favorites_already_exists():
    mock_db_session.query.return_value.filter.return_value.first.return_value = Favorite(id=1, user_id=1, book_id=1)
    response = client.post("/favorites/1")
    assert response.status_code == 400
    assert response.json() == {"detail": "Book already in favorites"}


def test_remove_from_favorites():
    mock_db_session.query.return_value.filter.return_value.first.return_value = Favorite(id=1, user_id=1, book_id=1)
    response = client.delete("/favorites/1")
    assert response.status_code == 200
    assert response.json() == {"detail": "Book removed from favorites"}


def test_remove_from_favorites_not_found():
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/favorites/1")
    assert response.status_code == 404
    assert response.json() == {"detail": "Favorite not found"}