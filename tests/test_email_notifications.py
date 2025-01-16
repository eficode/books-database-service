from unittest.mock import patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

@patch('fastapi_demo.email.send_email')
def test_schedule_email_notification(mock_send_email):
    with patch('fastapi_demo.time.get_current_time', return_value='08:00 AM'):
        response = client.get('/schedule-email-notification')
        assert response.status_code == 200
        mock_send_email.assert_called_once()

@patch('fastapi_demo.email.send_email')
def test_schedule_email_notification_negative(mock_send_email):
    with patch('fastapi_demo.time.get_current_time', return_value='07:59 AM'):
        response = client.get('/schedule-email-notification')
        assert response.status_code == 200
        mock_send_email.assert_not_called()

@patch('fastapi_demo.email.send_email')
def test_email_content(mock_send_email):
    mock_send_email.return_value = 'Book1: 100 sales\nBook2: 90 sales\n'
    response = client.get('/schedule-email-notification')
    assert response.status_code == 200
    email_content = mock_send_email.call_args[0][1]
    assert 'Book1: 100 sales' in email_content
    assert 'Book2: 90 sales' in email_content
    assert email_content == 'Book1: 100 sales\nBook2: 90 sales\n'

@patch('fastapi_demo.email.send_email')
def test_email_content_negative(mock_send_email):
    mock_send_email.return_value = 'Incorrect content'
    response = client.get('/schedule-email-notification')
    assert response.status_code == 200
    email_content = mock_send_email.call_args[0][1]
    assert email_content != 'Book1: 100 sales\nBook2: 90 sales\n'