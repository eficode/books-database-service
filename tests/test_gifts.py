from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Gift
from unittest.mock import MagicMock
from fastapi_demo.database import get_db

client = TestClient(app)
mock_db_session = MagicMock()

# Override the get_db dependency
app.dependency_overrides[get_db] = lambda: mock_db_session

def test_create_gift_success():
    mock_db_session.add.return_value = None
    mock_db_session.commit.return_value = None
    mock_db_session.refresh.return_value = None
    mock_db_session.query.return_value.filter.return_value.first.return_value = Gift(id=1, book_id=1, friend_name="John Doe", friend_address="123 Main St", status="pending")
    response = client.post("/gifts/", json={
        "book_id": 1,
        "friend_name": "John Doe",
        "friend_address": "123 Main St"
    })
    assert response.status_code == 201
    assert response.json() == {
        "id": 1,
        "book_id": 1,
        "friend_name": "John Doe",
        "friend_address": "123 Main St",
        "status": "pending"
    }

def test_create_gift_invalid_data():
    response = client.post("/gifts/", json={
        "book_id": "invalid",
        "friend_name": "",
        "friend_address": ""
    })
    assert response.status_code == 422