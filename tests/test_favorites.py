from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Favorite, Book
from fastapi import HTTPException

client = TestClient(app)

@patch('fastapi_demo.routers.favorites.get_db')
@patch('fastapi_demo.auth.get_current_user')
def test_add_to_favorites_network_error(mock_current_user, mock_get_db):
    mock_current_user.return_value = MagicMock(id=1)
    mock_get_db.side_effect = Exception("Network error")
    response = client.post("/favorites/", json={"book_id": 1})
    assert response.status_code == 500
    assert response.json().get("detail") == "Network error: Unable to add to favorites"

@patch('fastapi_demo.routers.favorites.get_db')
@patch('fastapi_demo.auth.get_current_user')
def test_get_favorites_server_error(mock_current_user, mock_get_db):
    mock_current_user.return_value = MagicMock(id=1)
    mock_get_db.side_effect = Exception("Server error")
    response = client.get("/favorites/")
    assert response.status_code == 500
    assert response.json().get("detail") == "Server error: Unable to load favorites list"

@patch('fastapi_demo.routers.favorites.get_db')
@patch('fastapi_demo.auth.get_current_user')
def test_remove_from_favorites_network_error(mock_current_user, mock_get_db):
    mock_current_user.return_value = MagicMock(id=1)
    mock_get_db.side_effect = Exception("Network error")
    response = client.delete("/favorites/1")
    assert response.status_code == 500
    assert response.json().get("detail") == "Network error: Unable to remove from favorites"