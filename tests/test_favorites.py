from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Favorite
from unittest.mock import MagicMock, patch
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session():
    return MagicMock()

app.dependency_overrides[get_db] = mock_db_session

# Test for adding a book to favorites with network issue
@patch('fastapi_demo.routers.favorites.add_favorite', side_effect=Exception('Network issue'))
def test_add_favorite_network_issue(mock_add_favorite):
    response = client.post("/favorites/", json={"user_id": 1, "book_id": 1})
    assert response.status_code == 503
    assert response.json().get("detail") == "Network issue, please try again later"

# Test for viewing favorites with server error
@patch('fastapi_demo.routers.favorites.view_favorites', side_effect=Exception('Server error'))
def test_view_favorites_server_error(mock_view_favorites):
    response = client.get("/favorites/")
    assert response.status_code == 500
    assert response.json().get("detail") == "Server error, please try again later"

# Test for removing a book from favorites with network issue
@patch('fastapi_demo.routers.favorites.remove_favorite', side_effect=Exception('Network issue'))
def test_remove_favorite_network_issue(mock_remove_favorite):
    response = client.delete("/favorites/1")
    assert response.status_code == 503
    assert response.json().get("detail") == "Network issue, please try again later"
