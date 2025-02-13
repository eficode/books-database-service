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
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.delete("/books/1")
    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"

def test_delete_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

def test_get_most_sold_books_default(mock_db_session):
    mock_db_session.query.return_value.order_by.return_value.all.return_value = [
        Book(id=1, title="Book 1", author="Author 1", pages=100, sales=50, rating=4.5, date_sold="2023-01-01"),
        Book(id=2, title="Book 2", author="Author 2", pages=150, sales=30, rating=4.0, date_sold="2023-01-02")
    ]
    response = client.get("/books/most-sold")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]["title"] == "Book 1"
    assert response.json()[1]["title"] == "Book 2"

def test_get_most_sold_books_sorted_by_date(mock_db_session):
    mock_db_session.query.return_value.order_by.return_value.all.return_value = [
        Book(id=2, title="Book 2", author="Author 2", pages=150, sales=30, rating=4.0, date_sold="2023-01-02"),
        Book(id=1, title="Book 1", author="Author 1", pages=100, sales=50, rating=4.5, date_sold="2023-01-01")
    ]
    response = client.get("/books/most-sold?sort_by=date")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]["title"] == "Book 2"
    assert response.json()[1]["title"] == "Book 1"

def test_get_most_sold_books_sorted_by_rating(mock_db_session):
    mock_db_session.query.return_value.order_by.return_value.all.return_value = [
        Book(id=1, title="Book 1", author="Author 1", pages=100, sales=50, rating=4.5, date_sold="2023-01-01"),
        Book(id=2, title="Book 2", author="Author 2", pages=150, sales=30, rating=4.0, date_sold="2023-01-02")
    ]
    response = client.get("/books/most-sold?sort_by=rating")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]["title"] == "Book 1"
    assert response.json()[1]["title"] == "Book 2"

def test_get_most_sold_books_sorted_by_author(mock_db_session):
    mock_db_session.query.return_value.order_by.return_value.all.return_value = [
        Book(id=1, title="Book 1", author="Author 1", pages=100, sales=50, rating=4.5, date_sold="2023-01-01"),
        Book(id=2, title="Book 2", author="Author 2", pages=150, sales=30, rating=4.0, date_sold="2023-01-02")
    ]
    response = client.get("/books/most-sold?sort_by=author")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]["title"] == "Book 1"
    assert response.json()[1]["title"] == "Book 2"
