from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

@patch('fastapi_demo.database.SessionLocal')
def test_create_book(mock_db_session):
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100,
        "isbn": "1234567890"
    })
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

@patch('fastapi_demo.database.SessionLocal')
def test_read_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    response = client.get("/books/1")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

@patch('fastapi_demo.database.SessionLocal')
def test_read_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.database.SessionLocal')
def test_update_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", pages=100, isbn="1234567890")
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200,
        "isbn": "1234567890"
    })
    assert response.status_code == 200
    assert response.json().get("title") == "New Title"
    assert response.json().get("author") == "New Author"
    assert response.json().get("pages") == 200

@patch('fastapi_demo.database.SessionLocal')
def test_update_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200,
        "isbn": "1234567890"
    })
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.database.SessionLocal')
def test_delete_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    response = client.delete("/books/1")
    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"

@patch('fastapi_demo.database.SessionLocal')
def test_delete_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.database.SessionLocal')
def test_search_book_by_isbn_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, isbn="1234567890")
    response = client.get("/books/search?isbn=1234567890")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

@patch('fastapi_demo.database.SessionLocal')
def test_search_book_by_isbn_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/search?isbn=1234567890")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.database.SessionLocal')
def test_search_book_by_isbn_db_error(mock_db_session):
    mock_db_session.query.return_value.filter.side_effect = Exception("DB error")
    response = client.get("/books/search?isbn=1234567890")
    assert response.status_code == 500
    assert response.json().get("detail") == "The search could not be completed"

@patch('fastapi_demo.database.SessionLocal')
def test_create_book_invalid_isbn(mock_db_session):
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100,
        "isbn": "123"
    })
    assert response.status_code == 422
    assert response.json().get("detail")[0]["msg"] == "ISBN must be either 10 or 13 characters long"

@patch('fastapi_demo.database.SessionLocal')
def test_update_book_invalid_isbn(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", pages=100, isbn="1234567890")
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200,
        "isbn": "123"
    })
    assert response.status_code == 422
    assert response.json().get("detail")[0]["msg"] == "ISBN must be either 10 or 13 characters long"

@patch('fastapi_demo.database.SessionLocal')
def test_view_book_details_rendering_issue(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.side_effect = Exception("Rendering issue")
    response = client.get("/books/1")
    assert response.status_code == 500
    assert response.json().get("detail") == "The details could not be displayed"

@patch('fastapi_demo.database.SessionLocal')
def test_view_books_list_rendering_issue(mock_db_session):
    mock_db_session.query.return_value.all.side_effect = Exception("Rendering issue")
    response = client.get("/books/")
    assert response.status_code == 500
    assert response.json().get("detail") == "The list could not be displayed"
