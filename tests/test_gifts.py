from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Gift
from fastapi import HTTPException
from unittest.mock import patch
from datetime import datetime

client = TestClient(app)

def test_create_gift_missing_recipient_details():
    response = client.post("/gifts/", json={
        "book_id": 1,
        "recipient_name": "",
        "recipient_address": "",
        "personal_message": "Happy Birthday!"
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "Recipient name and address are required"

@patch('fastapi_demo.routers.gifts.get_db')
def test_create_gift_success(mock_get_db):
    mock_db_session = mock_get_db.return_value.__enter__.return_value
    response = client.post("/gifts/", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St",
        "personal_message": "Happy Birthday!",
        "sender_email": "sender@example.com",
        "recipient_email": "recipient@example.com"
    })
    assert response.status_code == 201
    assert response.json().get("recipient_name") == "John Doe"
    assert response.json().get("recipient_address") == "123 Main St"

@patch('fastapi_demo.routers.gifts.get_db')
def test_read_gift_success(mock_get_db):
    mock_db_session = mock_get_db.return_value.__enter__.return_value
    mock_db_session.query.return_value.filter.return_value.first.return_value = Gift(
        id=1,
        book_id=1,
        recipient_name="John Doe",
        recipient_address="123 Main St",
        personal_message="Happy Birthday!",
        estimated_delivery_date=datetime.now(),
        sender_email="sender@example.com",
        recipient_email="recipient@example.com"
    )
    response = client.get("/gifts/1")
    assert response.status_code == 200
    assert response.json().get("recipient_name") == "John Doe"
    assert response.json().get("recipient_address") == "123 Main St"

@patch('fastapi_demo.routers.gifts.get_db')
def test_read_gift_not_found(mock_get_db):
    mock_db_session = mock_get_db.return_value.__enter__.return_value
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/gifts/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Gift not found"
