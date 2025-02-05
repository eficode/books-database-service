from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from sqlalchemy.orm import Session
from unittest.mock import MagicMock

client = TestClient(app)

def test_get_best_selling_books_no_results(mock_db_session):
    mock_db_session.query.return_value.all.return_value = []
    response = client.get("/best_selling_books/")
    assert response.status_code == 200
    assert response.json() == {"message": "No results found"}


def test_filter_best_selling_books_empty_category(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.count.return_value = 0
    response = client.get("/best_selling_books/?category=NonExistentCategory")
    assert response.status_code == 200
    assert response.json() == {"message": "No books found in this category"}


def test_sort_best_selling_books_no_sales_data(mock_db_session):
    mock_db_session.query.return_value.order_by.return_value.count.return_value = 0
    response = client.get("/best_selling_books/?sort_by_sales=true")
    assert response.status_code == 200
    assert response.json() == {"message": "No sales data available"}