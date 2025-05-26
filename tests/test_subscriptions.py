from fastapi.testclient import TestClient
from fastapi_demo.main import app
from unittest.mock import patch

client = TestClient(app)

@patch("fastapi_demo.utils.process_payment")
def test_subscribe_to_scifi_invalid_payment(mock_process_payment):
    mock_process_payment.return_value.status = "failed"
    response = client.post("/subscriptions/", json={
        "user_id": 1,
        "delivery_details": {
            "address": "123 SciFi St",
            "city": "Fictionville",
            "postal_code": "12345",
            "country": "Imaginary"
        },
        "payment_info": {
            "card_number": "1234567890123456",
            "expiry_date": "12/24",
            "cvv": "123"
        }
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "Payment failed"

@patch("fastapi_demo.utils.fetch_top_selling_sci_fi_book")
def test_receive_scifi_book_delivery_issue(mock_fetch_top_selling_sci_fi_book):
    mock_fetch_top_selling_sci_fi_book.return_value = None
    response = client.post("/subscriptions/1/deliver")
    assert response.status_code == 400
    assert response.json().get("detail") == "Delivery delayed"
