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
        "pages": 100,
        "cover_color": "red"
    })
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100
    assert response.json().get("cover_color") == "red"

@patch('fastapi_demo.routers.books.get_db')
def test_read_book_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, cover_color="red")
    response = client.get("/books/1")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100
    assert response.json().get("cover_color") == "red"

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
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", pages=100, cover_color="red")
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200,
        "cover_color": "blue"
    })
    assert response.status_code == 200
    assert response.json().get("title") == "New Title"
    assert response.json().get("author") == "New Author"
    assert response.json().get("pages") == 200
    assert response.json().get("cover_color") == "blue"

@patch('fastapi_demo.routers.books.get_db')
def test_update_book_not_found(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200,
        "cover_color": "blue"
    })
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.routers.books.get_db')
def test_delete_book_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, cover_color="red")
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

@patch('fastapi_demo.routers.books.get_db')
def test_search_books_by_cover_color_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Test Book 1", author="Test Author 1", pages=100, cover_color="red"),
        Book(id=2, title="Test Book 2", author="Test Author 2", pages=200, cover_color="red")
    ]
    response = client.get("/books/search?cover_color=red")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0].get("title") == "Test Book 1"
    assert response.json()[0].get("cover_color") == "red"
    assert response.json()[1].get("title") == "Test Book 2"
    assert response.json()[1].get("cover_color") == "red"

@patch('fastapi_demo.routers.books.get_db')
def test_search_books_by_cover_color_not_found(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/books/search?cover_color=purple")
    assert response.status_code == 404
    assert response.json().get("detail") == "No books found with the specified cover color"

@patch('fastapi_demo.routers.books.get_db')
def test_search_books_by_cover_color_error(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.side_effect = Exception("Database error")
    response = client.get("/books/search?cover_color=red")
    assert response.status_code == 500
    assert response.json().get("detail") == "The search could not be completed"
