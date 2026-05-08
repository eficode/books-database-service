from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Favorite

client = TestClient(app)

# Mock current user dependency
current_user = 1

# Add to Favorites

def test_add_to_favorites_success(mock_db_session):
    response = client.post("/favorites/", json={"book_id": 1})
    assert response.status_code == 201
    assert response.json().get("book_id") == 1
    assert response.json().get("user_id") == current_user

# Get Favorites

def test_get_favorites_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Favorite(id=1, user_id=current_user, book_id=1)
    ]
    response = client.get("/favorites/")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0].get("book_id") == 1
    assert response.json()[0].get("user_id") == current_user

# Remove from Favorites

def test_remove_from_favorites_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Favorite(id=1, user_id=current_user, book_id=1)
    response = client.delete("/favorites/1")
    assert response.status_code == 200
    assert response.json().get("detail") == "Favorite removed"

def test_remove_from_favorites_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/favorites/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Favorite not found"
