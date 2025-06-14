from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Gift

client = TestClient(app)

@patch('fastapi_demo.routers.gifts.send_email', MagicMock())
def test_create_gift():
    response = client.post("/gifts/", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St",
        "recipient_country": "USA"
    })
    assert response.status_code == 201
    assert response.json().get("book_id") == 1
    assert response.json().get("recipient_name") == "John Doe"
    assert response.json().get("recipient_address") == "123 Main St"
    assert response.json().get("recipient_country") == "USA"
    assert response.json().get("status") == "pending"
