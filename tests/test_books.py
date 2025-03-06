from fastapi.testclient import TestClient
from fastapi_demo.main import app
from unittest.mock import patch
import pytest

client = TestClient(app)

@patch('fastapi_demo.routers.books.get_db')
def test_get_top_sold_books_network_issue(mock_get_db):
    mock_get_db.side_effect = Exception("Network issue")
    response = client.get("/top-sold-books/")
    assert response.status_code == 500
    assert response.json() == {"detail": "Data could not be loaded due to a network issue"}

@patch('fastapi_demo.routers.books.get_db')
def test_export_top_sold_books_server_error(mock_get_db):
    mock_get_db.side_effect = Exception("Server error")
    response = client.get("/top-sold-books/export/")
    assert response.status_code == 500
    assert response.json() == {"detail": "Export failed due to a server error"}

@patch('fastapi_demo.routers.books.get_db')
def test_get_top_sold_books_invalid_date_range(mock_get_db):
    response = client.get("/top-sold-books/?start_date=invalid-date&end_date=invalid-date")
    assert response.status_code == 422
    assert response.json() == {"detail": "Invalid date range"}

@patch('fastapi_demo.routers.books.get_db')
def test_export_top_sold_books_invalid_date_range(mock_get_db):
    response = client.get("/top-sold-books/export/?start_date=invalid-date&end_date=invalid-date")
    assert response.status_code == 422
    assert response.json() == {"detail": "Invalid date range"}