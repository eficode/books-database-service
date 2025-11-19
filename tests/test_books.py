from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

# Mock database session
@patch('fastapi_demo.routers.books.get_db')
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

@patch('fastapi_demo.routers.books.get_db')
def test_read_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.get("/books/1")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

@patch('fastapi_demo.routers.books.get_db')
def test_read_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.routers.books.get_db')
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

@patch('fastapi_demo.routers.books.get_db')
def test_update_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200
    })
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.routers.books.get_db')
def test_delete_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.delete("/books/1")
    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"

@patch('fastapi_demo.routers.books.get_db')
def test_delete_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.routers.books.get_db')
def test_search_book_by_valid_isbn(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    response = client.get("/books/search?isbn=1234567890")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100
    assert response.json().get("isbn") == "1234567890"

@patch('fastapi_demo.routers.books.get_db')
def test_search_book_by_invalid_isbn(mock_db_session):
    response = client.get("/books/search?isbn=invalid_isbn")
    assert response.status_code == 400
    assert response.json().get("detail") == "The ISBN is invalid"

@patch('fastapi_demo.routers.books.get_db')
def test_search_book_by_empty_isbn(mock_db_session):
    response = client.get("/books/search?isbn=")
    assert response.status_code == 400
    assert response.json().get("detail") == "The ISBN field cannot be empty"

@patch('fastapi_demo.routers.books.get_db')
def test_search_book_by_nonexistent_isbn(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/search?isbn=0000000000")
    assert response.status_code == 404
    assert response.json().get("detail") == "No books were found"
