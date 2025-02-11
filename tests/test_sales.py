from unittest.mock import patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, Sales
from fastapi_demo.routers.sales import get_daily_report
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session():
    with patch('fastapi_demo.database.SessionLocal') as mock:
        yield mock

@patch('fastapi_demo.routers.sales.get_daily_report')
def test_get_daily_report_success(mock_get_daily_report, mock_db_session):
    mock_get_daily_report.return_value = {
        "report": [
            {
                "genre": "Fiction",
                "books": [
                    {
                        "title": "Book A",
                        "author": "Author A",
                        "sales_volume": 100
                    }
                ]
            }
        ]
    }
    response = client.get("/sales/daily-report")
    assert response.status_code == 200
    assert response.json() == {
        "report": [
            {
                "genre": "Fiction",
                "books": [
                    {
                        "title": "Book A",
                        "author": "Author A",
                        "sales_volume": 100
                    }
                ]
            }
        ]
    }

@patch('fastapi_demo.routers.sales.get_daily_report')
def test_get_daily_report_no_data(mock_get_daily_report, mock_db_session):
    mock_get_daily_report.return_value = {"report": []}
    response = client.get("/sales/daily-report")
    assert response.status_code == 200
    assert response.json() == {"report": []}
