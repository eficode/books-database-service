from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

@patch('fastapi_demo.routers.books.get_db')
def test_search_books_success(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title='Book 1', author='Author A', pages=100),
        Book(id=2, title='Book 2', author='Author A', pages=200)
    ]
    response = client.get('/books/search?author=Author A')
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0]['author'] == 'Author A'
    assert response.json()[1]['author'] == 'Author A'

@patch('fastapi_demo.routers.books.get_db')
def test_search_books_no_results(mock_get_db):
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get('/books/search?author=NonExistingAuthor')
    assert response.status_code == 404
    assert response.json().get('detail') == 'No books found for the given author'
