from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import User, Book, Delivery
from unittest.mock import patch
import pytest

client = TestClient(app)

@pytest.fixture
@patch('fastapi_demo.database.SessionLocal', autospec=True)
def mock_db_session(mock_session):
    yield mock_session.return_value

@patch('fastapi_demo.routers.schedule_delivery.send_email')
def test_schedule_delivery_no_books(mock_send_email, mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = User(id=1, email="test@example.com", address="123 Test St", favorites="")
    response = client.post("/schedule-delivery/", json={"user_id": 1})
    assert response.status_code == 200
    assert response.json().get("message") == "No books available for delivery"

@patch('fastapi_demo.routers.schedule_delivery.send_email')
def test_notify_delivery_invalid_email(mock_send_email, mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.side_effect = [User(id=1, email="invalid-email", address="123 Test St", favorites="1,2,3"), Book(id=1, title="Test Book")]
    response = client.post("/notify-delivery/", json={"user_id": 1, "book_id": 1})
    assert response.status_code == 200
    assert response.json().get("message") == "Invalid email address"
