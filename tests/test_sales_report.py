from fastapi.testclient import TestClient
from fastapi_demo.main import app
from unittest.mock import patch, MagicMock
import pytest

client = TestClient(app)

@pytest.fixture
@patch('fastapi_demo.routers.sales_report.get_db')
def mock_db_session(mock_get_db):
    mock_session = MagicMock()
    mock_get_db.return_value = mock_session
    return mock_session

@patch('fastapi_demo.routers.sales_report.get_db')
def test_get_sales_report(mock_get_db):
    mock_session = MagicMock()
    mock_get_db.return_value = mock_session
    mock_session.query.return_value.order_by.return_value.limit.return_value.all.side_effect = [
        [
            MagicMock(title='Book A', author='Author A', sales=100),
            MagicMock(title='Book B', author='Author B', sales=90)
        ],
        [
            MagicMock(title='Book C', author='Author C', sales=10),
            MagicMock(title='Book D', author='Author D', sales=5)
        ]
    ]
    response = client.get('/sales-report')
    assert response.status_code == 200
    assert response.json() == {
        'most_sold_books': [
            {'title': 'Book A', 'author': 'Author A', 'sales': 100},
            {'title': 'Book B', 'author': 'Author B', 'sales': 90}
        ],
        'least_sold_books': [
            {'title': 'Book C', 'author': 'Author C', 'sales': 10},
            {'title': 'Book D', 'author': 'Author D', 'sales': 5}
        ]
    }
