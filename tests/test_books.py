from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

# Test for top-selling sports books
@patch('fastapi_demo.routers.books.get_db')
def test_get_top_selling_sports_books_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.order_by.return_value.limit.return_value.all.return_value = [
        Book(id=1, title="Sports Book 1", author="Author 1", pages=100, category="Sports", sales=50),
        Book(id=2, title="Sports Book 2", author="Author 2", pages=150, category="Sports", sales=30)
    ]
    response = client.get("/top-selling-sports-books/")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]["title"] == "Sports Book 1"
    assert response.json()[1]["title"] == "Sports Book 2"

@patch('fastapi_demo.routers.books.get_db')
def test_get_top_selling_sports_books_not_available(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.order_by.return_value.limit.return_value.all.return_value = []
    response = client.get("/top-selling-sports-books/")
    assert response.status_code == 404
    assert response.json()["detail"] == "Mother's Day gift section not available"

# Test for quick purchase
@patch('fastapi_demo.routers.books.get_db')
def test_quick_purchase_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Sports Book 1", author="Author 1", pages=100, category="Sports", sales=50, stock=10)
    response = client.post("/quick-purchase/", json={"book_id": 1})
    assert response.status_code == 201
    assert response.json()["message"] == "Book added to cart successfully"

@patch('fastapi_demo.routers.books.get_db')
def test_quick_purchase_book_not_found(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.post("/quick-purchase/", json={"book_id": 1})
    assert response.status_code == 404
    assert response.json()["detail"] == "Book not found"

@patch('fastapi_demo.routers.books.get_db')
def test_quick_purchase_book_out_of_stock(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Sports Book 1", author="Author 1", pages=100, category="Sports", sales=50, stock=0)
    response = client.post("/quick-purchase/", json={"book_id": 1})
    assert response.status_code == 400
    assert response.json()["detail"] == "Book is out of stock"
