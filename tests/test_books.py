from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

# Mock database session
mock_db_session = MagicMock()

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_create_book(mock_db_session):
    response = client.post('/books/', json={
        'title': 'Test Book',
        'author': 'Test Author',
        'pages': 100,
        'price': 9.99
    })
    assert response.status_code == 200
    assert response.json().get('title') == 'Test Book'
    assert response.json().get('author') == 'Test Author'
    assert response.json().get('pages') == 100
    assert response.json().get('price') == 9.99

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_read_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title='Test Book', author='Test Author', pages=100, price=9.99)
    response = client.get('/books/1')
    assert response.status_code == 200
    assert response.json().get('title') == 'Test Book'
    assert response.json().get('author') == 'Test Author'
    assert response.json().get('pages') == 100
    assert response.json().get('price') == 9.99

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_read_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get('/books/1')
    assert response.status_code == 404
    assert response.json().get('detail') == 'Book not found'

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_update_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title='Old Title', author='Old Author', pages=100, price=9.99)
    response = client.put('/books/1', json={
        'title': 'New Title',
        'author': 'New Author',
        'pages': 200,
        'price': 19.99
    })
    assert response.status_code == 200
    assert response.json().get('title') == 'New Title'
    assert response.json().get('author') == 'New Author'
    assert response.json().get('pages') == 200
    assert response.json().get('price') == 19.99

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_update_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put('/books/1', json={
        'title': 'New Title',
        'author': 'New Author',
        'pages': 200,
        'price': 19.99
    })
    assert response.status_code == 404
    assert response.json().get('detail') == 'Book not found'

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_delete_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title='Test Book', author='Test Author', pages=100, price=9.99)
    response = client.delete('/books/1')
    assert response.status_code == 200
    assert response.json().get('message') == 'Book deleted successfully'

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_delete_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete('/books/1')
    assert response.status_code == 404
    assert response.json().get('detail') == 'Book not found'

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_read_books_no_books(mock_db_session):
    mock_db_session.query.return_value.all.return_value = []
    response = client.get('/books/')
    assert response.status_code == 404
    assert response.json().get('detail') == 'No books available'

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_read_books_incomplete_data(mock_db_session):
    mock_db_session.query.return_value.all.return_value = [
        Book(id=1, title='Test Book', author='Test Author', pages=100, price=None)
    ]
    response = client.get('/books/')
    assert response.status_code == 400
    assert response.json().get('detail') == 'Some book information is missing'

@patch('fastapi_demo.routers.books.get_db', return_value=mock_db_session)
def test_read_books_backend_failure(mock_db_session):
    mock_db_session.query.side_effect = Exception('Database error')
    response = client.get('/books/')
    assert response.status_code == 500
    assert response.json().get('detail') == 'Books could not be loaded'
