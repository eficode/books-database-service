from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Product
from unittest.mock import patch

client = TestClient(app)

@patch('fastapi_demo.main.add_to_cart')
@patch('fastapi_demo.main.get_db')
def test_order_immediately_success(mock_get_db, mock_add_to_cart):
    mock_db = mock_get_db.return_value.__enter__.return_value
    mock_db.query.return_value.filter.return_value.first.return_value = Product(id=1, name="Test Product", price=100, stock=10)
    mock_add_to_cart.return_value = None
    response = client.post("/order-immediately/1")
    assert response.status_code == 200
    assert response.json() == {
        "message": "Product added to cart and redirected to checkout",
        "checkout_url": "https://example.com/checkout"
    }

@patch('fastapi_demo.main.get_db')
def test_order_immediately_product_not_found(mock_get_db):
    mock_db = mock_get_db.return_value.__enter__.return_value
    mock_db.query.return_value.filter.return_value.first.return_value = None
    response = client.post("/order-immediately/1")
    assert response.status_code == 404
    assert response.json() == {"detail": "Product not found"}

@patch('fastapi_demo.main.add_to_cart')
@patch('fastapi_demo.main.get_db')
def test_order_immediately_add_to_cart_failure(mock_get_db, mock_add_to_cart):
    mock_db = mock_get_db.return_value.__enter__.return_value
    mock_db.query.return_value.filter.return_value.first.return_value = Product(id=1, name="Test Product", price=100, stock=10)
    mock_add_to_cart.side_effect = Exception("Failed to add product to cart")
    response = client.post("/order-immediately/1")
    assert response.status_code == 500
    assert response.json() == {"detail": "Failed to add product to cart"}
