from unittest.mock import MagicMock
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Order
from fastapi_demo.database import get_db

client = TestClient(app)
mock_db_session = MagicMock()

# Override the get_db dependency
app.dependency_overrides[get_db] = lambda: mock_db_session

def test_create_order_invalid_address():
    response = client.post("/orders/", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": ""
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid address"


def test_create_order_invalid_name():
    response = client.post("/orders/", json={
        "book_id": 1,
        "recipient_name": "",
        "recipient_address": "Valid Address"
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "Recipient name is required"


def test_create_order_success():
    mock_db_session.add.return_value = None
    mock_db_session.commit.return_value = None
    mock_db_session.refresh.return_value = None
    response = client.post("/orders/", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "Valid Address"
    })
    assert response.status_code == 201
    assert response.json().get("recipient_name") == "John Doe"
    assert response.json().get("recipient_address") == "Valid Address"
