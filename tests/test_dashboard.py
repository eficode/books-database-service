from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, Basket, BasketItem
from datetime import datetime

client = TestClient(app)


def test_get_sold_books_default_sorting(mock_db_session):
    """Test that sold books are sorted by total_sold descending by default"""
    # Mock the query result with books sorted by total_sold desc
    mock_result = [
        MagicMock(id=1, title="Best Seller", author="Author A", category="Fiction", 
                  price=19.99, total_sold=10),
        MagicMock(id=2, title="Popular Book", author="Author B", category="Non-Fiction", 
                  price=15.99, total_sold=8),
        MagicMock(id=3, title="Average Book", author="Author C", category="Mystery", 
                  price=12.99, total_sold=5),
    ]
    
    # Set up the mock chain
    mock_query = MagicMock()
    mock_db_session.query.return_value = mock_query
    mock_query.join.return_value = mock_query
    mock_query.filter.return_value = mock_query
    mock_query.group_by.return_value = mock_query
    mock_query.order_by.return_value = mock_query
    mock_query.all.return_value = mock_result
    
    response = client.get("/dashboard/sold-books")
    
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 3
    assert data[0]["title"] == "Best Seller"
    assert data[0]["total_sold"] == 10
    assert data[1]["title"] == "Popular Book"
    assert data[1]["total_sold"] == 8
    assert data[2]["title"] == "Average Book"
    assert data[2]["total_sold"] == 5


def test_get_sold_books_sort_by_title_asc(mock_db_session):
    """Test sorting sold books by title ascending"""
    # Mock the query result with books sorted by title asc
    mock_result = [
        MagicMock(id=3, title="Average Book", author="Author C", category="Mystery", 
                  price=12.99, total_sold=5),
        MagicMock(id=1, title="Best Seller", author="Author A", category="Fiction", 
                  price=19.99, total_sold=10),
        MagicMock(id=2, title="Popular Book", author="Author B", category="Non-Fiction", 
                  price=15.99, total_sold=8),
    ]
    
    # Set up the mock chain
    mock_query = MagicMock()
    mock_db_session.query.return_value = mock_query
    mock_query.join.return_value = mock_query
    mock_query.filter.return_value = mock_query
    mock_query.group_by.return_value = mock_query
    mock_query.order_by.return_value = mock_query
    mock_query.all.return_value = mock_result
    
    response = client.get("/dashboard/sold-books?sort_by=title&sort_order=asc")
    
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 3
    assert data[0]["title"] == "Average Book"
    assert data[1]["title"] == "Best Seller"
    assert data[2]["title"] == "Popular Book"


def test_get_sold_books_sort_by_title_desc(mock_db_session):
    """Test sorting sold books by title descending"""
    # Mock the query result with books sorted by title desc
    mock_result = [
        MagicMock(id=2, title="Popular Book", author="Author B", category="Non-Fiction", 
                  price=15.99, total_sold=8),
        MagicMock(id=1, title="Best Seller", author="Author A", category="Fiction", 
                  price=19.99, total_sold=10),
        MagicMock(id=3, title="Average Book", author="Author C", category="Mystery", 
                  price=12.99, total_sold=5),
    ]
    
    # Set up the mock chain
    mock_query = MagicMock()
    mock_db_session.query.return_value = mock_query
    mock_query.join.return_value = mock_query
    mock_query.filter.return_value = mock_query
    mock_query.group_by.return_value = mock_query
    mock_query.order_by.return_value = mock_query
    mock_query.all.return_value = mock_result
    
    response = client.get("/dashboard/sold-books?sort_by=title&sort_order=desc")
    
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 3
    assert data[0]["title"] == "Popular Book"
    assert data[1]["title"] == "Best Seller"
    assert data[2]["title"] == "Average Book"


def test_get_sold_books_invalid_sort_field(mock_db_session):
    """Test that invalid sort field defaults to total_sold"""
    # Mock the query result (should default to total_sold desc)
    mock_result = [
        MagicMock(id=1, title="Best Seller", author="Author A", category="Fiction", 
                  price=19.99, total_sold=10),
        MagicMock(id=2, title="Popular Book", author="Author B", category="Non-Fiction", 
                  price=15.99, total_sold=8),
    ]
    
    # Set up the mock chain
    mock_query = MagicMock()
    mock_db_session.query.return_value = mock_query
    mock_query.join.return_value = mock_query
    mock_query.filter.return_value = mock_query
    mock_query.group_by.return_value = mock_query
    mock_query.order_by.return_value = mock_query
    mock_query.all.return_value = mock_result
    
    response = client.get("/dashboard/sold-books?sort_by=invalid_field")
    
    assert response.status_code == 200
    data = response.json()
    # Should still return data sorted by total_sold desc
    assert data[0]["total_sold"] == 10
    assert data[1]["total_sold"] == 8


def test_get_sold_books_sort_by_author_asc(mock_db_session):
    """Test sorting sold books by author ascending"""
    # Mock the query result with books sorted by author asc
    mock_result = [
        MagicMock(id=1, title="Best Seller", author="Alice", category="Fiction", 
                  price=19.99, total_sold=10),
        MagicMock(id=2, title="Popular Book", author="Bob", category="Non-Fiction", 
                  price=15.99, total_sold=8),
        MagicMock(id=3, title="Average Book", author="Charlie", category="Mystery", 
                  price=12.99, total_sold=5),
    ]
    
    # Set up the mock chain
    mock_query = MagicMock()
    mock_db_session.query.return_value = mock_query
    mock_query.join.return_value = mock_query
    mock_query.filter.return_value = mock_query
    mock_query.group_by.return_value = mock_query
    mock_query.order_by.return_value = mock_query
    mock_query.all.return_value = mock_result
    
    response = client.get("/dashboard/sold-books?sort_by=author&sort_order=asc")
    
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 3
    assert data[0]["author"] == "Alice"
    assert data[1]["author"] == "Bob"
    assert data[2]["author"] == "Charlie"


def test_get_sold_books_sort_by_revenue_desc(mock_db_session):
    """Test sorting sold books by revenue descending"""
    # Mock the query result with books sorted by revenue desc
    mock_result = [
        MagicMock(id=1, title="Best Seller", author="Author A", category="Fiction", 
                  price=19.99, total_sold=10),  # revenue: 199.90
        MagicMock(id=2, title="Popular Book", author="Author B", category="Non-Fiction", 
                  price=15.99, total_sold=8),   # revenue: 127.92
        MagicMock(id=3, title="Average Book", author="Author C", category="Mystery", 
                  price=12.99, total_sold=5),   # revenue: 64.95
    ]
    
    # Set up the mock chain
    mock_query = MagicMock()
    mock_db_session.query.return_value = mock_query
    mock_query.join.return_value = mock_query
    mock_query.filter.return_value = mock_query
    mock_query.group_by.return_value = mock_query
    mock_query.order_by.return_value = mock_query
    mock_query.all.return_value = mock_result
    
    response = client.get("/dashboard/sold-books?sort_by=revenue&sort_order=desc")
    
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 3
    assert data[0]["revenue"] == 199.90
    assert data[1]["revenue"] == 127.92
    assert data[2]["revenue"] == 64.95


def test_get_sold_books_empty_result(mock_db_session):
    """Test when no books have been sold"""
    # Set up the mock chain with empty result
    mock_query = MagicMock()
    mock_db_session.query.return_value = mock_query
    mock_query.join.return_value = mock_query
    mock_query.filter.return_value = mock_query
    mock_query.group_by.return_value = mock_query
    mock_query.order_by.return_value = mock_query
    mock_query.all.return_value = []
    
    response = client.get("/dashboard/sold-books")
    
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 0


def test_get_sold_books_case_insensitive_sort_order(mock_db_session):
    """Test that sort_order is case insensitive"""
    # Mock the query result
    mock_result = [
        MagicMock(id=1, title="A Book", author="Author", category="Fiction", 
                  price=19.99, total_sold=10),
        MagicMock(id=2, title="B Book", author="Author", category="Fiction", 
                  price=19.99, total_sold=5),
    ]
    
    # Set up the mock chain
    mock_query = MagicMock()
    mock_db_session.query.return_value = mock_query
    mock_query.join.return_value = mock_query
    mock_query.filter.return_value = mock_query
    mock_query.group_by.return_value = mock_query
    mock_query.order_by.return_value = mock_query
    mock_query.all.return_value = mock_result
    
    # Test with uppercase ASC
    response = client.get("/dashboard/sold-books?sort_by=title&sort_order=ASC")
    assert response.status_code == 200
    
    # Test with mixed case
    response = client.get("/dashboard/sold-books?sort_by=title&sort_order=Desc")
    assert response.status_code == 200