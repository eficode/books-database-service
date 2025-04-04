from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from unittest.mock import MagicMock
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session():
    db_session = MagicMock()
    yield db_session

# Test for no sales data available
def test_get_quarterly_sales_no_data(mock_db_session):
    mock_db_session.query.return_value.count.return_value = 0
    response = client.get("/sales/quarterly")
    assert response.status_code == 200
    assert response.json() == {"message": "No sales data available for the last quarter."}

# Test for successful export
def test_export_quarterly_sales_success(mock_db_session):
    mock_db_session.query.return_value.count.return_value = 10
    response = client.post("/sales/export")
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"

# Test for export failure
def test_export_quarterly_sales_failure(mock_db_session):
    mock_db_session.query.side_effect = Exception("Database error")
    response = client.post("/sales/export")
    assert response.status_code == 500
    assert response.json() == {"message": "Export failed"}