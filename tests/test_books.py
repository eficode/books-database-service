from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

@patch('fastapi_demo.routers.books.get_db')
def test_create_book(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "isbn": "1234567890",
        "genre": "Fiction",
        "price": 19.99
    })
    assert response.status_code == 201
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("isbn") == "1234567890"
    assert response.json().get("genre") == "Fiction"
    assert response.json().get("price") == 19.99

@patch('fastapi_demo.routers.books.get_db')
def test_read_book_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", isbn="1234567890", genre="Fiction", price=19.99)
    response = client.get("/books/1")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("isbn") == "1234567890"
    assert response.json().get("genre") == "Fiction"
    assert response.json().get("price") == 19.99

@patch('fastapi_demo.routers.books.get_db')
def test_read_book_not_found(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.routers.books.get_db')
def test_update_book_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", isbn="1234567890", genre="Fiction", price=19.99)
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "isbn": "0987654321",
        "genre": "Non-Fiction",
        "price": 29.99
    })
    assert response.status_code == 200
    assert response.json().get("title") == "New Title"
    assert response.json().get("author") == "New Author"
    assert response.json().get("isbn") == "0987654321"
    assert response.json().get("genre") == "Non-Fiction"
    assert response.json().get("price") == 29.99

@patch('fastapi_demo.routers.books.get_db')
def test_update_book_not_found(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "isbn": "0987654321",
        "genre": "Non-Fiction",
        "price": 29.99
    })
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.routers.books.get_db')
def test_delete_book_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", isbn="1234567890", genre="Fiction", price=19.99)
    response = client.delete("/books/1")
    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"

@patch('fastapi_demo.routers.books.get_db')
def test_delete_book_not_found(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"
