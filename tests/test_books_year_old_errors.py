from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from sqlalchemy.exc import OperationalError

client = TestClient(app)

def test_get_books_year_old_db_connection_error():
    with patch('fastapi_demo.routers.books.get_db') as mock_get_db:
        mock_get_db.side_effect = OperationalError("Mocked operational error", None, None)
        response = client.get("/books/year-old")
        assert response.status_code == 500
        assert response.json().get("detail") == "Database connection error"

def test_get_books_year_old_unexpected_error():
    with patch('fastapi_demo.routers.books.get_db') as mock_get_db:
        mock_get_db.side_effect = Exception("Mocked unexpected error")
        response = client.get("/books/year-old")
        assert response.status_code == 500
        assert response.json().get("detail") == "Unexpected error occurred"
