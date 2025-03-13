from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
import pytest

client = TestClient(app)

@pytest.fixture
def mock_liked_books(mock_db_session):
    # Mock liked books
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Book(id=1, title="Liked Book 1", author="Author 1", pages=100, favorite=True),
        Book(id=2, title="Liked Book 2", author="Author 2", pages=150, favorite=True)
    ]

from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
import pytest

client = TestClient(app)

@pytest.fixture
def mock_liked_books(mock_db_session):
    # Mock liked books
    liked_books = [
        Book(id=1, title="Liked Book 1", author="Author 1", pages=100, favorite=True),
        Book(id=2, title="Liked Book 2", author="Author 2", pages=150, favorite=True)
    ]
    mock_db_session.query.return_value.filter.return_value.all.return_value = liked_books
    return liked_books
    response = client.get("/books/liked")
    assert response.status_code == 200
    liked_books = response.json()
    assert len(liked_books) == 2
    assert liked_books[0]["title"] == "Liked Book 1"
    assert liked_books[1]["title"] == "Liked Book 2"

def test_read_liked_books(mock_liked_books):
    response = client.get("/books/liked")
    assert response.status_code == 200
    liked_books_response = response.json()
    assert len(liked_books_response) == len(mock_liked_books)
    for i, book in enumerate(mock_liked_books):
        assert liked_books_response[i]["title"] == book.title
    # Mock no liked books
    mock_db_session.query.return_value.filter.return_value.all.return_value = []

    response = client.get("/books/liked")
    assert response.status_code == 200
    liked_books = response.json()
    assert len(liked_books) == 0
def test_read_liked_books_empty(mock_db_session):
    # Mock no liked books
    mock_db_session.query.return_value.filter.return_value.all.return_value = []

    response = client.get("/books/liked")
    assert response.status_code == 200
    liked_books_response = response.json()
    assert len(liked_books_response) == 0
