from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, Sale
from fastapi import HTTPException
from datetime import date

client = TestClient(app)

@patch('fastapi_demo.database.SessionLocal')
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

@patch('fastapi_demo.database.SessionLocal')
def test_read_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
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

@patch('fastapi_demo.database.SessionLocal')
def test_update_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200
    })
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

@patch('fastapi_demo.database.SessionLocal')
def test_delete_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
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
def test_get_low_selling_books_no_sales_data(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.group_by.return_value.having.return_value.all.return_value = []
    response = client.get("/books/low-selling-books/?start_date=2023-01-01&end_date=2023-01-31")
    assert response.status_code == 404
    assert response.json().get("detail") == "No sales data available for the specified period"

@patch('fastapi_demo.database.SessionLocal')
def test_get_low_selling_books_with_sales_data(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.group_by.return_value.having.return_value.all.return_value = [Sale(book_id=1, total_sales=0)]
    mock_db_session.query.return_value.filter.return_value.all.return_value = [Book(id=1, title="Test Book", author="Test Author", pages=100)]
    response = client.get("/books/low-selling-books/?start_date=2023-01-01&end_date=2023-01-31")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0].get("title") == "Test Book"
    assert response.json()[0].get("author") == "Test Author"
    assert response.json()[0].get("pages") == 100
