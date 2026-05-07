from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
import requests

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


def test_fetch_book_price_success():
    with patch("requests.get") as mock_get:
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {"price": 19.99}
        response = client.get("/books/amazon-price/1234567890")
        assert response.status_code == 200
        assert response.json().get("price") == 19.99


def test_fetch_book_price_amazon_api_down():
    with patch("requests.get") as mock_get:
        mock_get.side_effect = requests.RequestException
        response = client.get("/books/amazon-price/1234567890")
        assert response.status_code == 503
        assert response.json().get("detail") == "Price is unavailable"


def test_update_book_price_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, price=10.0)
    response = client.put("/books/1/price", json={"price": 20.0})
    assert response.status_code == 200
    assert response.json().get("price") == 20.0


def test_update_book_price_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put("/books/1/price", json={"price": 20.0})
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"


def test_update_book_price_invalid_price(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, price=10.0)
    response = client.put("/books/1/price", json={"price": -5.0})
    assert response.status_code == 400
    assert response.json().get("detail") == "Price update failed"
