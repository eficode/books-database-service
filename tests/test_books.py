# FILEPATH: /Users/alexjantunen/dev/fast-api-demo/test_main.py
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
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
    """
    Test successful deletion of a single book.
    """
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)

    response = client.delete("/books/1")

    assert response.status_code == 200, "Expected status code 200 for successful deletion"
    assert response.json().get("detail") == "Book deleted", "Expected detail message 'Book deleted'"

def test_delete_book_not_found(mock_db_session):
    """
    Test deletion of a non-existent book.
    """
    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.delete("/books/1")

    assert response.status_code == 404, "Expected status code 404 for book not found"
    assert response.json().get("detail") == "Book not found", "Expected detail message 'Book not found'"

def test_bulk_delete_books_success(mock_db_session):
    """
    Test successful bulk deletion of multiple books.
    """
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book 1", author="Test Author 1", pages=100),
        Book(id=2, title="Test Book 2", author="Test Author 2", pages=150)
    ]

    response = client.delete("/books/bulk", json={"book_ids": [1, 2]}, headers={"Content-Type": "application/json"})

    assert response.status_code == 200, "Expected status code 200 for successful bulk deletion"
    assert response.json().get("detail") == "Books deleted", "Expected detail message 'Books deleted'"

def test_bulk_delete_books_not_found(mock_db_session):
    """
    Test bulk deletion with one or more non-existent books.
    """
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book 1", author="Test Author 1", pages=100)
    ]

    response = client.delete("/books/bulk", json={"book_ids": [1, 2]}, headers={"Content-Type": "application/json"})

    assert response.status_code == 404, "Expected status code 404 for one or more books not found"
    assert response.json().get("detail") == "One or more books not found", "Expected detail message 'One or more books not found'"
