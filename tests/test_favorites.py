from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, Favorite
from unittest.mock import MagicMock
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session():
    return MagicMock()

@pytest.fixture
def override_get_db(mock_db_session):
    app.dependency_overrides[get_db] = lambda: mock_db_session
    yield
    app.dependency_overrides.clear()

@pytest.fixture
def mock_current_user():
    return 1

@pytest.fixture
def override_get_current_user(mock_current_user):
    app.dependency_overrides[get_current_user] = lambda: mock_current_user
    yield
    app.dependency_overrides.clear()

@pytest.mark.usefixtures("override_get_db", "override_get_current_user")
def test_read_favorites_no_favorites(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/favorites/")
    assert response.status_code == 200
    assert response.json() == []

@pytest.mark.usefixtures("override_get_db", "override_get_current_user")
def test_add_favorite_already_exists(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Favorite(id=1, user_id=1, book_id=1)
    response = client.post("/favorites/", json={"book_id": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "The book is already in your favorites"

@pytest.mark.usefixtures("override_get_db", "override_get_current_user")
def test_remove_favorite_not_exists(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/favorites/1")
    assert response.status_code == 400
    assert response.json().get("detail") == "The book cannot be removed as it is not in your favorites"