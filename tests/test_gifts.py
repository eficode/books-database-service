from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import GiftOrder
from unittest.mock import MagicMock
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session():
    return MagicMock()

app.dependency_overrides[get_db] = mock_db_session


def test_create_gift_order_invalid_address(mock_db_session):
    response = client.post("/gifts/mothers-day", json={
        "gift_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "123"
    })
    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid delivery address"


def test_create_gift_order_success(mock_db_session):
    mock_db_session.add.return_value = None
    mock_db_session.commit.return_value = None
    mock_db_session.refresh.return_value = None
    response = client.post("/gifts/mothers-day", json={
        "gift_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St"
    })
    assert response.status_code == 201
    assert "order_id" in response.json()
    assert response.json()["status"] == "pending"


def test_get_gift_order_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/gifts/mothers-day/1")
    assert response.status_code == 404
    assert response.json()["detail"] == "Order not found"


def test_get_gift_order_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = GiftOrder(
        id=1, gift_id=1, recipient_name="John Doe", recipient_address="123 Main St", status="pending"
    )
    response = client.get("/gifts/mothers-day/1")
    assert response.status_code == 200
    assert response.json()["order_id"] == 1
    assert response.json()["status"] == "pending"
