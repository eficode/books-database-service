from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

def test_search_books_by_genre_no_results(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get('/books/search?genre=sci-fi')
    assert response.status_code == 404
    assert response.json().get('detail') == 'No books found in the sci-fi genre.'

def test_search_books_by_keyword_no_results(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get('/books/search?keyword=sci-fi')
    assert response.status_code == 404
    assert response.json().get('detail') == 'No books found matching the keyword sci-fi.'
