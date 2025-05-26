from unittest.mock import MagicMock
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import GiftOrder

client = TestClient(app)

# Test for invalid address
def test_create_gift_order_invalid_address(mock_db_session):
    response = client.post("/gifts/mothers-day", json={
        "gift_id": 1,
        "recipient_name": "Mom",
        "recipient_address": "invalid",
        "message": "Happy Mother's Day!"
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid address provided"

# Test for successful gift order creation
def test_create_gift_order_success(mock_db_session):
    mock_db_session.add.return_value = None
    mock_db_session.commit.return_value = None
    mock_db_session.refresh.return_value = None
    response = client.post("/gifts/mothers-day", json={
        "gift_id": 1,
        "recipient_name": "Mom",
        "recipient_address": "123 Main St",
        "message": "Happy Mother's Day!"
    })
    assert response.status_code == 201
    assert response.json().get("recipient_name") == "Mom"
    assert response.json().get("recipient_address") == "123 Main St"

# Test for checking order status
def test_get_gift_order_status(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = GiftOrder(
        id=1,
        gift_id=1,
        recipient_name="Mom",
        recipient_address="123 Main St",
        message="Happy Mother's Day!",
        status="Pending"
    )
    response = client.get("/gifts/mothers-day/1/status")
    assert response.status_code == 200
    assert response.json().get("status") == "Pending"

# Test for order not found
def test_get_gift_order_status_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/gifts/mothers-day/1/status")
    assert response.status_code == 404
    assert response.json().get("detail") == "Order not found"
