from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
from sqlalchemy.exc import SQLAlchemyError

client = TestClient(app)

# Mock database session dependency
@patch('fastapi_demo.database.SessionLocal', MagicMock())
@patch('fastapi_demo.dependencies.get_db', MagicMock())
def test_delete_all_test_books_success():
    with patch('fastapi_demo.dependencies.get_current_user', return_value=User(is_test_manager=True)):
        response = client.delete('/books/test')
        assert response.status_code == 200
        assert response.json().get('detail') == 'All test books have been deleted'

@patch('fastapi_demo.database.SessionLocal', MagicMock())
@patch('fastapi_demo.dependencies.get_db', MagicMock())
def test_delete_all_test_books_insufficient_permissions():
    with patch('fastapi_demo.dependencies.get_current_user', return_value=User(is_test_manager=False)):
        response = client.delete('/books/test')
        assert response.status_code == 403
        assert response.json().get('detail') == 'Insufficient permissions'

@patch('fastapi_demo.database.SessionLocal', MagicMock())
@patch('fastapi_demo.dependencies.get_db', MagicMock())
def test_delete_all_test_books_database_error():
    with patch('fastapi_demo.dependencies.get_current_user', return_value=User(is_test_manager=True)):
        with patch('sqlalchemy.orm.Query.delete', side_effect=SQLAlchemyError):
            response = client.delete('/books/test')
            assert response.status_code == 500
            assert response.json().get('detail') == 'Database error occurred'