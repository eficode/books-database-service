# FILEPATH: /Users/alexjantunen/dev/fast-api-demo/test_main.py
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
import pytest
from datetime import datetime, timedelta
from fastapi_demo.models import Book
from sqlalchemy import func
from fastapi_demo.dtos import BookInfo
from fastapi_demo.main import app
from fastapi_demo.models import Book
from datetime import datetime, timedelta
from fastapi_demo.models import Book

from fastapi import HTTPException

client = TestClient(app)

def test_create_book(mock_db_session):
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100
    })

    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

def test_read_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.get("/books/1")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

def test_read_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"


def test_update_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", pages=100)

    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200
    })

    assert response.status_code == 200
    assert response.json().get("title") == "New Title"
    assert response.json().get("author") == "New Author"
    assert response.json().get("pages") == 200

def test_update_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200
    })

    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

def test_delete_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)

    response = client.delete("/books/1")

    assert response.status_code == 204

@pytest.mark.parametrize("books, expected_status, expected_length", [
    ([
        Book(id=1, title="Week Old Book", author="Author", pages=123, added_date=(datetime.now() - timedelta(days=7)).date())
    ], 200, 1),
    ([
        Book(id=2, title="Older Book", author="Author", pages=123, added_date=(datetime.now() - timedelta(days=8)).date())
    ], 404, 0),
    ([
        Book(id=3, title="Newer Book", author="Author", pages=123, added_date=(datetime.now() - timedelta(days=6)).date())
    ], 404, 0),
    ([], 404, 0)
])
def test_get_week_old_books(mock_db_session, books, expected_status, expected_length):
    mock_db_session.query.return_value.filter.return_value.all.return_value = books
    response = client.get("/books/week-old")
    assert response.status_code == expected_status
    if expected_status == 200:
        assert len(response.json()) == expected_length
        assert response.json()[0].get("title") == "Week Old Book"
        assert response.json()[0].get("author") == "Author"
        assert response.json()[0].get("pages") == 123
        assert response.json()[0].get("added_date") == (datetime.now() - timedelta(days=7)).date().isoformat()
    else:
        assert response.json().get("detail") == "No books found that are a week old"
