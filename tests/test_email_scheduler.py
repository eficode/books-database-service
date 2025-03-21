from unittest.mock import patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

@patch('fastapi_demo.email_service.send_weekly_email')
def test_send_weekly_email_success(mock_send_email):
    mock_send_email.return_value = None
    response = client.post("/email_scheduler/send_weekly_email")
    assert response.status_code == 200
    assert response.json().get("message") == "Weekly email sent"

@patch('fastapi_demo.email_service.send_weekly_email')
def test_send_weekly_email_failure(mock_send_email):
    mock_send_email.side_effect = Exception("Email service error")
    response = client.post("/email_scheduler/send_weekly_email")
    assert response.status_code == 500
    assert response.json().get("detail") == "Weekly email not sent"