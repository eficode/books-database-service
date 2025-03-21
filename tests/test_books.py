from fastapi.testclient import TestClient
from fastapi_demo.main import app
import requests
from unittest.mock import patch
import time

client = TestClient(app)

@patch('fastapi_demo.routers.books.is_authenticated', return_value=True)
def test_get_top_selling_books_invalid_category(mock_is_authenticated):
    response = client.get("/top-selling-books/InvalidCategory")
    assert response.status_code == 400
    assert response.json() == {"detail": "Invalid category"}

@patch('fastapi_demo.routers.books.is_authenticated', return_value=False)
def test_get_top_selling_books_not_authenticated(mock_is_authenticated):
    response = client.get("/top-selling-books/Fiction")
    assert response.status_code == 401
    assert response.json() == {"detail": "Not authenticated. Please log in."}

@patch('requests.get')
@patch('fastapi_demo.routers.books.is_authenticated', return_value=True)
def test_get_top_selling_books_api_failure(mock_is_authenticated, mock_requests_get):
    mock_requests_get.side_effect = requests.exceptions.RequestException
    response = client.get("/top-selling-books/Fiction")
    assert response.status_code == 503
    assert response.json() == {"detail": "Service is unavailable"}

@patch('requests.get')
@patch('fastapi_demo.routers.books.is_authenticated', return_value=True)
def test_get_top_selling_books_slow_response(mock_is_authenticated, mock_requests_get):
    class MockSlowResponse:
        status_code = 200
        def json(self):
            return [{"title": "Book 1", "author": "Author 1", "sales_rank": 1}]
    mock_requests_get.return_value = MockSlowResponse()
    with patch('time.time', side_effect=[0, 3]):
        response = client.get("/top-selling-books/Fiction")
        assert response.status_code == 200
        assert response.json() == {"message": "The request is taking longer than expected", "data": [{"title": "Book 1", "author": "Author 1", "sales_rank": 1}]}
