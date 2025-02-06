from unittest.mock import MagicMock
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, ShoppingCart

client = TestClient(app)

# Mock session
mock_db_session = MagicMock()

# Override the dependency
app.dependency_overrides[get_db] = lambda: mock_db_session

# Test adding a book to the cart when the book is out of stock

def test_add_book_to_cart_out_of_stock():
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, stock=0)
    response = client.post("/cart/add", json={"book_id": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "The book is out of stock"

# Test viewing an empty shopping cart

def test_view_empty_cart():
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/cart")
    assert response.status_code == 200
    assert response.json().get("detail") == "Your shopping cart is empty"
