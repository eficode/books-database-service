# FILEPATH: /Users/alexjantunen/dev/fast-api-demo/test_main.py
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, Comment

from fastapi import HTTPException
from fastapi_demo.models import Comment
from fastapi_demo.dtos import CommentCreate

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

    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"

def test_add_comment_success(mock_db_session):
    mock_db_session.add.return_value = None
    mock_db_session.commit.return_value = None
    mock_db_session.refresh.return_value = None

    response = client.post("/books/1/comments", json={"book_id": 1, "user_id": 1, "content": "Great book!"})
    assert response.status_code == 200
    assert response.json().get("content") == "Great book!"

def test_add_comment_empty_content(mock_db_session):
    response = client.post("/books/1/comments", json={"book_id": 1, "user_id": 1, "content": ""})
    assert response.status_code == 400
    assert response.json().get("detail") == "Comment cannot be empty"

def test_toggle_favorite_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, favorite=False)

    response = client.patch("/books/1/favorite", json={"favorite": True})

    assert response.status_code == 200
    assert response.json().get("favorite") is True

def test_toggle_favorite_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.patch("/books/1/favorite", json={"favorite": True})

    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Comment(id=1, book_id=1, user_id=1, content="Great book!"),
        Comment(id=2, book_id=1, user_id=2, content="Loved it!")
    ]
    response = client.get("/books/1/comments")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0].get("content") == "Great book!"
    assert response.json()[1].get("content") == "Loved it!"
    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.delete("/books/1")

    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"
