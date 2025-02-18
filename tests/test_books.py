from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

# Existing test cases...

def test_get_top_rated_books_no_results(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.order_by.return_value.limit.return_value.all.return_value = []
    response = client.get("/books/top-rated")
    assert response.status_code == 404
    assert response.json().get("detail") == "No top-rated software development books found"
