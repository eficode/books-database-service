from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
import io

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

def test_delete_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

def test_import_books_success(mock_db_session):
    json_data = '[{"title": "Book 1", "author": "Author 1", "pages": 100}, {"title": "Book 2", "author": "Author 2", "pages": 200}]'
    response = client.post("/books/import", files={"file": ("test.json", io.BytesIO(json_data.encode()), "application/json")})
    assert response.status_code == 200
    assert response.json().get("message") == "Books imported successfully"
    assert response.json().get("imported_count") == 2

def test_import_books_invalid_json(mock_db_session):
    invalid_json_data = '[{"title": "Book 1", "author": "Author 1", "pages": 100}, {"title": "Book 2", "author": "Author 2", "pages": 200]'
    response = client.post("/books/import", files={"file": ("test.json", io.BytesIO(invalid_json_data.encode()), "application/json")})
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid JSON format."

def test_import_books_validation_error(mock_db_session):
    invalid_book_data = '[{"title": "Book 1", "author": "Author 1", "pages": 100}, {"title": "Book 2", "author": "Author 2"}]'
    response = client.post("/books/import", files={"file": ("test.json", io.BytesIO(invalid_book_data.encode()), "application/json")})
    assert response.status_code == 400
    assert response.json().get("error") == "Validation error"
    assert "pages" in response.json().get("details")[0]
