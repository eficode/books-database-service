from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from unittest.mock import MagicMock, patch

client = TestClient(app)

@patch('fastapi_demo.routers.inventory.get_db')
def test_get_inventory_dashboard(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.all.return_value = [
        Book(id=1, title="Book 1", author="Author 1", pages=100, stock_level=5, reorder_threshold=10),
        Book(id=2, title="Book 2", author="Author 2", pages=200, stock_level=15, reorder_threshold=10)
    ]
    response = client.get("/inventory/dashboard")
    assert response.status_code == 200
    assert response.json() == {
        "books": [
            {
                "id": 1,
                "title": "Book 1",
                "author": "Author 1",
                "pages": 100,
                "stock_level": 5,
                "reorder_needed": True
            },
            {
                "id": 2,
                "title": "Book 2",
                "author": "Author 2",
                "pages": 200,
                "stock_level": 15,
                "reorder_needed": False
            }
        ]
    }
