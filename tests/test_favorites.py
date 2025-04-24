from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import FavoriteAuthor
from unittest.mock import MagicMock
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session():
    return MagicMock()

client.app.dependency_overrides[get_db] = mock_db_session

# Add Author to Favorites - unsuccessful scenario

def test_add_author_to_favorites_already_exists(mock_db_session):
    mock_db_session.query.return_value.filter_by.return_value.first.return_value = FavoriteAuthor(id=1, user_id=1, author_id=1)
    response = client.post("/favorites/authors/", json={"author_id": 1})
    assert response.status_code == 400
    assert response.json()["detail"] == "Author is already in favorites"

# View Favorites List - unsuccessful scenario

def test_view_favorites_list_no_favorites(mock_db_session):
    mock_db_session.query.return_value.filter_by.return_value.all.return_value = []
    response = client.get("/favorites/authors/")
    assert response.status_code == 404
    assert response.json()["detail"] == "No favorite authors found"

# Remove Author from Favorites - unsuccessful scenario

def test_remove_author_from_favorites_not_found(mock_db_session):
    mock_db_session.query.return_value.filter_by.return_value.first.return_value = None
    response = client.delete("/favorites/authors/1")
    assert response.status_code == 404
    assert response.json()["detail"] == "Author not found in favorites"