from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Gift, Cart, RecipientAddress, Order
from fastapi import HTTPException
from unittest.mock import patch

client = TestClient(app)

def test_add_gift_to_cart_out_of_stock(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Gift(id=1, name="Test Gift", price=10.0, description="Test Description", stock=0)
    response = client.post("/mothers-day-gifts/cart/", json={"gift_id": 1, "quantity": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "The item is out of stock"

def test_enter_recipient_address_invalid(mock_db_session):
    response = client.post("/mothers-day-gifts/checkout/recipient-address/", json={"cart_id": 1, "recipient_name": "Test Name", "recipient_address": "123"})
    assert response.status_code == 400
    assert response.json().get("detail") == "The address is invalid"

def test_confirm_order_missing_or_incorrect_address(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.post("/mothers-day-gifts/checkout/confirm/", json={"cart_id": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "The recipient's address is missing or incorrect"

def test_send_order_confirmation_email_failure(mock_db_session):
    with patch("fastapi_demo.routers.gifts.send_order_confirmation_email", return_value=False):
        response = client.post("/mothers-day-gifts/notifications/send-confirmation/", json={"order_id": 1, "email": "test@example.com"})
        assert response.status_code == 500
        assert response.json().get("detail") == "Failed to send order confirmation email"