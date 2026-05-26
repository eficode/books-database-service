from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
from fastapi_demo.amazon_service import AmazonAPIError

client = TestClient(app)

 def test_create_book(mock_db_session):
    with patch('fastapi_demo.amazon_service.AmazonService.get_book_price', return_value=19.99):
        response = client.post("/books/", json={
            "title": "Test Book",
            "author": "Test Author",
            "pages": 100
        })
        assert response.status_code == 200
        assert response.json().get("title") == "Test Book"
        assert response.json().get("author") == "Test Author"
        assert response.json().get("pages") == 100
        assert response.json().get("price") == 19.99

 def test_create_book_price_unavailable(mock_db_session):
    with patch('fastapi_demo.amazon_service.AmazonService.get_book_price', side_effect=AmazonAPIError):
        response = client.post("/books/", json={
            "title": "Test Book",
            "author": "Test Author",
            "pages": 100
        })
        assert response.status_code == 200
        assert response.json().get("title") == "Test Book"
        assert response.json().get("author") == "Test Author"
        assert response.json().get("pages") == 100
        assert response.json().get("price") is None

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
    with patch('fastapi_demo.amazon_service.AmazonService.get_book_price', return_value=29.99):
        response = client.put("/books/1", json={
            "title": "New Title",
            "author": "New Author",
            "pages": 200
        })
        assert response.status_code == 200
        assert response.json().get("title") == "New Title"
        assert response.json().get("author") == "New Author"
        assert response.json().get("pages") == 200
        assert response.json().get("price") == 29.99

 def test_update_book_price_unavailable(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", pages=100, price=19.99)
    with patch('fastapi_demo.amazon_service.AmazonService.get_book_price', side_effect=AmazonAPIError):
        response = client.put("/books/1", json={
            "title": "New Title",
            "author": "New Author",
            "pages": 200
        })
        assert response.status_code == 200
        assert response.json().get("title") == "New Title"
        assert response.json().get("author") == "New Author"
        assert response.json().get("pages") == 200
        assert response.json().get("price") == 19.99 # Old price should still be displayed

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
