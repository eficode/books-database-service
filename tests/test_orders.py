from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Order
from fastapi import HTTPException

client = TestClient(app)

def test_create_order(mock_db_session):
    response = client.post("/orders/", json={
        "customer_id": 1,
        "book_id": 1,
        "boosted_delivery": True
    })
    assert response.status_code == 201
    assert response.json().get("customer_id") == 1
    assert response.json().get("book_id") == 1
    assert response.json().get("status") == "Processing"
    assert response.json().get("estimated_delivery_time") in ["2023-10-10T10:00:00Z", "2023-10-20T10:00:00Z"]


def test_read_order_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Order(id=1, customer_id=1, book_id=1, boosted_delivery=True, status="Processing", estimated_delivery_time="2023-10-10T10:00:00Z")
    response = client.get("/orders/1")
    assert response.status_code == 200
    assert response.json().get("customer_id") == 1
    assert response.json().get("book_id") == 1
    assert response.json().get("status") == "Processing"
    assert response.json().get("estimated_delivery_time") == "2023-10-10T10:00:00Z"


def test_read_order_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/orders/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Order not found"
