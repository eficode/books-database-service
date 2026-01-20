from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Favourite
from unittest.mock import MagicMock

client = TestClient(app)

# Mock user authentication
current_user = 1

# Mock database session
mock_db_session = MagicMock()

# Test adding a book to favourites

def test_add_favourite_success():
    response = client.post("/favourites/", json={"book_id": 1})
    assert response.status_code == 201
    assert response.json().get("book_id") == 1


def test_add_favourite_already_exists():
    mock_db_session.query.return_value.filter.return_value.first.return_value = Favourite(id=1, user_id=current_user, book_id=1)
    response = client.post("/favourites/", json={"book_id": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "The book is already in your favourites list"

# Test retrieving favourite books

def test_get_favourites_success():
    mock_db_session.query.return_value.filter.return_value.all.return_value = [Favourite(id=1, user_id=current_user, book_id=1)]
    response = client.get("/favourites/")
    assert response.status_code == 200
    assert len(response.json()) == 1


def test_get_favourites_empty():
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/favourites/")
    assert response.status_code == 404
    assert response.json().get("detail") == "No favourite books found"

# Test removing a book from favourites

def test_remove_favourite_success():
    mock_db_session.query.return_value.filter.return_value.first.return_value = Favourite(id=1, user_id=current_user, book_id=1)
    response = client.delete("/favourites/1")
    assert response.status_code == 200
    assert response.json().get("message") == "Book removed from favourites"


def test_remove_favourite_not_found():
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/favourites/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "The book is not in your favourites list"