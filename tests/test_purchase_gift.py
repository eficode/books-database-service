from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import PurchaseGift
from fastapi import HTTPException

client = TestClient(app)

@patch("fastapi_demo.services.ShippingService.ship_book")
@patch("fastapi_demo.services.EmailService.send_confirmation")
def test_purchase_gift_invalid_shipping(mock_send_confirmation, mock_ship_book, mock_db_session):
    mock_ship_book.side_effect = ValueError("Invalid shipping details")
    response = client.post("/purchase-gift/", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "",
        "recipient_email": "john.doe@example.com"
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid shipping details"

@patch("fastapi_demo.services.ShippingService.ship_book")
@patch("fastapi_demo.services.EmailService.send_confirmation")
def test_purchase_gift_email_service_down(mock_send_confirmation, mock_ship_book, mock_db_session):
    mock_ship_book.return_value = "tracking_number"
    mock_send_confirmation.side_effect = Exception("Email service down")
    response = client.post("/purchase-gift/", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St, Springfield, USA",
        "recipient_email": "john.doe@example.com"
    })
    assert response.status_code == 201
    assert response.json().get("status") == "shipped"
    assert response.json().get("message") == "Purchase successful"