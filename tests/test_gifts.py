from unittest.mock import MagicMock
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Gift

client = TestClient(app)
mock_db_session = MagicMock()

# Test for creating a Mother's Day gift with a non-UK address
def test_create_mothers_day_gift_non_uk_address():
    response = client.post("/gifts/mothers-day", json={
        "book_id": 1,
        "recipient_name": "Jane Doe",
        "recipient_address": "123 Main St",
        "recipient_city": "Some City",
        "recipient_postcode": "US12345"
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "Recipient's address must be within the UK"

# Test for creating a Mother's Day gift with incomplete details
def test_create_mothers_day_gift_incomplete_details():
    response = client.post("/gifts/mothers-day", json={
        "book_id": 1,
        "recipient_name": "Jane Doe",
        "recipient_address": "",
        "recipient_city": "Some City",
        "recipient_postcode": "UK12345"
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "All recipient details must be provided"

# Test for creating a Mother's Day gift successfully
def test_create_mothers_day_gift_success():
    response = client.post("/gifts/mothers-day", json={
        "book_id": 1,
        "recipient_name": "Jane Doe",
        "recipient_address": "123 Main St",
        "recipient_city": "Some City",
        "recipient_postcode": "UK12345"
    })
    assert response.status_code == 201
    assert response.json().get("recipient_name") == "Jane Doe"
    assert response.json().get("recipient_postcode") == "UK12345"

# Test for retrieving a Mother's Day gift
def test_read_mothers_day_gift():
    mock_db_session.query.return_value.filter.return_value.first.return_value = Gift(
        gift_id=1,
        book_id=1,
        recipient_name="Jane Doe",
        recipient_address="123 Main St",
        recipient_city="Some City",
        recipient_postcode="UK12345",
        status="Pending"
    )
    response = client.get("/gifts/mothers-day/1")
    assert response.status_code == 200
    assert response.json().get("recipient_name") == "Jane Doe"
    assert response.json().get("recipient_postcode") == "UK12345"

# Test for retrieving a non-existent Mother's Day gift
def test_read_mothers_day_gift_not_found():
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/gifts/mothers-day/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Gift not found"
