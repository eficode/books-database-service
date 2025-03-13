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

import pytest
from fastapi import HTTPException
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book

client = TestClient(app)

@pytest.fixture
def mock_liked_books(mock_db_session):
    liked_books = [
        Book(id=1, title="Liked Book 1", author="Author 1", pages=100, favorite=True, cover_image="cover1.jpg"),
        Book(id=2, title="Liked Book 2", author="Author 2", pages=150, favorite=True, cover_image="cover2.jpg")
    ]
    mock_db_session.query.return_value.filter.return_value.all.return_value = liked_books
    return liked_books

def test_read_liked_books_success(mock_db_session, mock_liked_books):
    response = client.get("/books/liked")
    assert response.status_code == 200
    data = response.json()
    assert data["total_count"] == len(mock_liked_books)
    assert len(data["books"]) == len(mock_liked_books)
    for i, book in enumerate(mock_liked_books):
        assert data["books"][i]["title"] == book.title
        assert data["books"][i]["author"] == book.author
        assert data["books"][i]["cover_image"] == book.cover_image

def test_read_liked_books_empty(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/books/liked")
    assert response.status_code == 200
    data = response.json()
    assert data["total_count"] == 0
    assert len(data["books"]) == 0

def test_read_liked_books_error(mock_db_session):
    mock_db_session.query.side_effect = Exception("Database error")
    response = client.get("/books/liked")
    assert response.status_code == 500
    assert "Database error" in response.json()["detail"]

@pytest.mark.parametrize("liked_books, expected_count", [
    ([
        Book(id=1, title="Liked Book 1", author="Author 1", pages=100, favorite=True, cover_image="cover1.jpg"),
        Book(id=2, title="Liked Book 2", author="Author 2", pages=150, favorite=True, cover_image="cover2.jpg")
    ], 2),
    ([], 0)
])
def test_read_liked_books(mock_db_session, liked_books, expected_count):
    # Mock liked books
    mock_db_session.query.return_value.filter.return_value.all.return_value = liked_books

    response = client.get("/books/liked")
    assert response.status_code == 200
    liked_books_response = response.json()
    assert len(liked_books_response) == expected_count
    if expected_count > 0:
        assert liked_books_response[0]["title"] == liked_books[0].title
        assert liked_books_response[0]["cover_image"] == liked_books[0].cover_image

def test_read_liked_books_api_success(mock_db_session, mock_liked_books):
    response = client.get("/books/liked")
    assert response.status_code == 200
    data = response.json()
    assert data["total_count"] == len(mock_liked_books)
    assert len(data["books"]) == len(mock_liked_books)
    for i, book in enumerate(mock_liked_books):
        assert data["books"][i]["title"] == book.title
        assert data["books"][i]["author"] == book.author
        assert data["books"][i]["cover_image"] == book.cover_image

def test_read_liked_books_api_empty(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/books/liked")
    assert response.status_code == 200
    data = response.json()
    assert data["total_count"] == 0
    assert len(data["books"]) == 0

def test_read_liked_books_api_error(mock_db_session):
    mock_db_session.query.side_effect = Exception("Database error")
    response = client.get("/books/liked")
    assert response.status_code == 500
    assert "Database error" in response.json()["detail"]


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

    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"

def test_delete_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.delete("/books/1")

    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"
