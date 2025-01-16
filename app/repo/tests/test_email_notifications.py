from unittest.mock import patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)


@patch('fastapi_demo.email.send_email')
def test_receive_daily_email_at_8_am(mock_send_email):
    with patch('fastapi_demo.utils.get_current_time', return_value='08:00 AM'):
        response = client.get('/send-daily-email')
        assert response.status_code == 200
        mock_send_email.assert_called_once()


@patch('fastapi_demo.email.send_email')
def test_not_receive_daily_email_before_8_am(mock_send_email):
    with patch('fastapi_demo.utils.get_current_time', return_value='07:59 AM'):
        response = client.get('/send-daily-email')
        assert response.status_code == 200
        mock_send_email.assert_not_called()


@patch('fastapi_demo.email.send_email')
def test_email_content(mock_send_email):
    mock_send_email.return_value = {
        'subject': 'Daily Sales Report',
        'body': '1. Book A by Author A - 100 sales\n2. Book B by Author B - 90 sales'
    }
    response = client.get('/send-daily-email')
    assert response.status_code == 200
    email_content = mock_send_email.call_args[1]['body']
    assert '1. Book A by Author A - 100 sales' in email_content
    assert '2. Book B by Author B - 90 sales' in email_content


@patch('fastapi_demo.email.send_email')
def test_email_content_negative_case(mock_send_email):
    mock_send_email.return_value = {
        'subject': 'Daily Sales Report',
        'body': 'Incorrect content'
    }
    response = client.get('/send-daily-email')
    assert response.status_code == 200
    email_content = mock_send_email.call_args[1]['body']
    assert 'Incorrect content' in email_content
