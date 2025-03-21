from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, AcademicLiterature
from fastapi import HTTPException

client = TestClient(app)

# Existing tests...

def test_create_book(mock_db_session):
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100
    })
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

def test_read_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.get("/books/1")
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100

def test_read_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

# New tests for related academic literature

def test_get_related_academic_literature_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        AcademicLiterature(id=1, title="Academic Work 1", author="Author 1", publication_year=1975, related_book_id=1),
        AcademicLiterature(id=2, title="Academic Work 2", author="Author 2", publication_year=1978, related_book_id=1)
    ]
    response = client.get("/books/1/related-academic-literature")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0].get("title") == "Academic Work 1"
    assert response.json()[1].get("title") == "Academic Work 2"

def test_get_related_academic_literature_no_data(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/books/1/related-academic-literature")
    assert response.status_code == 404
    assert response.json().get("detail") == "No related academic literature found"

def test_get_related_academic_literature_incomplete_data(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        AcademicLiterature(id=1, title=None, author="Author 1", publication_year=1975, related_book_id=1)
    ]
    response = client.get("/books/1/related-academic-literature")
    assert response.status_code == 400
    assert response.json().get("detail") == "Incomplete data for related academic literature"

def test_get_related_academic_literature_system_error(mock_db_session):
    mock_db_session.query.side_effect = Exception("Database error")
    response = client.get("/books/1/related-academic-literature")
    assert response.status_code == 500
    assert response.json().get("detail") == "System error while retrieving related academic literature"