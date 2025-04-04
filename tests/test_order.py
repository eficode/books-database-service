from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Order, OrderCreate
from unittest.mock import patch

client = TestClient(app)

@patch('fastapi_demo.auth.is_authenticated', return_value=False)
def test_order_immediately_unauthenticated(mock_is_authenticated):
    response = client.post("/order-immediately/", json={"product_id": 1, "user_id": 1})
    assert response.status_code == 401
    assert response.json() == {"detail": "Unauthorized"}

@patch('fastapi_demo.auth.is_authenticated', return_value=True)
def test_order_immediately_authenticated(mock_is_authenticated):
    response = client.post("/order-immediately/", json={"product_id": 1, "user_id": 1})
    assert response.status_code == 201
    assert "order_id" in response.json()
    assert response.json()["status"] == "pending"
