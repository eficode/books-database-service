from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Favourite, Book
from fastapi import HTTPException

client = TestClient(app)

# Mock data
mock_favourite = Favourite(id=1, user_id=1, book_id=1, position=0)
mock_book = Book(id=1, title="Test Book", author="Test Author", pages=100)

# Test cases

def test_get_favourites_no_favourites(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/favourites/")
    assert response.status_code == 404
    assert response.json().get("detail") == "No favourite books available."


def test_add_favourite_network_error(mock_db_session):
    mock_db_session.add.side_effect = Exception("Network error")
    response = client.post("/favourites/", json={"book_id": 1})
    assert response.status_code == 500
    assert response.json().get("detail") == "Network error. Please try again."


def test_remove_favourite_server_error(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = mock_favourite
    mock_db_session.delete.side_effect = Exception("Server error")
    response = client.delete("/favourites/1")
    assert response.status_code == 500
    assert response.json().get("detail") == "Server error. Please try again."


def test_reorder_favourites_client_error(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = mock_favourite
    mock_db_session.commit.side_effect = Exception("Client-side error")
    response = client.put("/favourites/reorder", json=[{"id": 1, "new_position": 1}])
    assert response.status_code == 500
    assert response.json().get("detail") == "Client-side error. Please try again."
