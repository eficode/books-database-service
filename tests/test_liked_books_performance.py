import time
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from unittest.mock import patch

client = TestClient(app)

def test_liked_books_performance(mock_db_session):
    # Mock a large number of liked books
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=i, title=f"Book {i}", author=f"Author {i}", pages=100, favorite=True)
        for i in range(1000)
    ]

    start_time = time.time()
    response = client.get("/books/liked")
    end_time = time.time()

    assert response.status_code == 200
    assert len(response.json()) == 1000
    assert (end_time - start_time) < 2, "The response time exceeded 2 seconds"
