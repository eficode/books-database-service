from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import SalesData, EmailReport
from fastapi import HTTPException
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session():
    return MagicMock()

@pytest.fixture
def mock_send_email():
    with patch('fastapi_demo.email.send_email') as mock:
        yield mock


def test_generate_and_send_daily_email_report(mock_db_session, mock_send_email):
    # Mock sales data for the previous day
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        SalesData(book_id=1, quantity_sold=10),
        SalesData(book_id=2, quantity_sold=5)
    ]

    response = client.post("/reports/daily-email")

    assert response.status_code == 200
    mock_send_email.assert_called_once()
    email_content = mock_send_email.call_args[1]['content']
    assert "Test Book" in email_content
    assert "10" in email_content
    assert "Test Book 2" in email_content
    assert "5" in email_content


def test_fail_to_generate_and_send_daily_email_report_due_to_missing_sales_data(mock_db_session, mock_send_email):
    # Mock no sales data for the previous day
    mock_db_session.query.return_value.filter.return_value.all.return_value = []

    response = client.post("/reports/daily-email")

    assert response.status_code == 400
    mock_send_email.assert_not_called()


def test_email_report_content(mock_db_session, mock_send_email):
    # Mock sales data for the previous day
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        SalesData(book_id=1, quantity_sold=10),
        SalesData(book_id=2, quantity_sold=5)
    ]

    response = client.post("/reports/daily-email")

    assert response.status_code == 200
    mock_send_email.assert_called_once()
    email_content = mock_send_email.call_args[1]['content']
    assert "Test Book" in email_content
    assert "10" in email_content
    assert "Test Book 2" in email_content
    assert "5" in email_content
    assert "Most Sold Books" in email_content


def test_fail_to_verify_email_report_content_due_to_formatting_issues(mock_db_session, mock_send_email):
    # Mock sales data for the previous day
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        SalesData(book_id=1, quantity_sold=10),
        SalesData(book_id=2, quantity_sold=5)
    ]

    with patch('fastapi_demo.email.format_email_content', return_value=""):
        response = client.post("/reports/daily-email")

    assert response.status_code == 200
    mock_send_email.assert_called_once()
    email_content = mock_send_email.call_args[1]['content']
    assert email_content == ""
