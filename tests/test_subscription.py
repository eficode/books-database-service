from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Subscription
from fastapi import HTTPException

client = TestClient(app)

@patch('fastapi_demo.email_service.send_confirmation_email')
def test_subscribe_success(mock_send_email, mock_db_session):
    mock_send_email.return_value = None
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.post("/subscription/subscribe", json={"email": "test@example.com"})
    assert response.status_code == 200
    assert response.json().get("email") == "test@example.com"
    assert response.json().get("confirmed") == False

@patch('fastapi_demo.email_service.send_confirmation_email')
def test_subscribe_email_already_registered(mock_send_email, mock_db_session):
    mock_send_email.return_value = None
    mock_db_session.query.return_value.filter.return_value.first.return_value = Subscription(id=1, email="test@example.com", confirmed=False)
    response = client.post("/subscription/subscribe", json={"email": "test@example.com"})
    assert response.status_code == 400
    assert response.json().get("detail") == "Email already registered"

@patch('fastapi_demo.email_service.send_confirmation_email')
def test_subscribe_confirmation_email_failure(mock_send_email, mock_db_session):
    mock_send_email.side_effect = Exception("Email service error")
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.post("/subscription/subscribe", json={"email": "test@example.com"})
    assert response.status_code == 500
    assert response.json().get("detail") == "Confirmation email not sent"

@patch('fastapi_demo.email_service.send_confirmation_email')
def test_unsubscribe_success(mock_send_email, mock_db_session):
    mock_send_email.return_value = None
    mock_db_session.query.return_value.filter.return_value.first.return_value = Subscription(id=1, email="test@example.com", confirmed=False)
    response = client.post("/subscription/unsubscribe", json={"email": "test@example.com"})
    assert response.status_code == 200
    assert response.json().get("message") == "Unsubscription confirmed"

@patch('fastapi_demo.email_service.send_confirmation_email')
def test_unsubscribe_email_not_found(mock_send_email, mock_db_session):
    mock_send_email.return_value = None
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.post("/subscription/unsubscribe", json={"email": "test@example.com"})
    assert response.status_code == 404
    assert response.json().get("detail") == "Email not found"