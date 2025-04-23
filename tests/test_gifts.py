from fastapi.testclient import TestClient
from fastapi_demo.main import app
from unittest.mock import patch
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session():
    with patch("fastapi_demo.database.SessionLocal") as mock:
        yield mock


def test_send_mothers_day_gift_invalid_shipping(mock_db_session):
    response = client.post("/gifts/mothers-day", json={
        "gift_id": 1,
        "mother_name": "Jane Doe",
        "mother_address": "",
        "mother_city": "",
        "mother_country": "",
        "payment_details": {
            "card_number": "1234567890123456",
            "expiry_date": "12/23",
            "cvv": "123"
        }
    })
    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid shipping details"


def test_send_mothers_day_gift_payment_failed(mock_db_session):
    with patch("fastapi_demo.utils.process_payment", return_value={"success": False}):
        response = client.post("/gifts/mothers-day", json={
            "gift_id": 1,
            "mother_name": "Jane Doe",
            "mother_address": "123 Main St",
            "mother_city": "Springfield",
            "mother_country": "USA",
            "payment_details": {
                "card_number": "1234567890123456",
                "expiry_date": "12/23",
                "cvv": "123"
            }
        })
        assert response.status_code == 400
        assert response.json()["detail"] == "Payment failed"


def test_send_mothers_day_gift_processing_error(mock_db_session):
    with patch("fastapi_demo.utils.call_shipping_service", side_effect=Exception("Shipping service error")):
        response = client.post("/gifts/mothers-day", json={
            "gift_id": 1,
            "mother_name": "Jane Doe",
            "mother_address": "123 Main St",
            "mother_city": "Springfield",
            "mother_country": "USA",
            "payment_details": {
                "card_number": "1234567890123456",
                "expiry_date": "12/23",
                "cvv": "123"
            }
        })
        assert response.status_code == 500
        assert response.json()["detail"] == "Gift processing failed"