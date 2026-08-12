from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException

client = TestClient(app)

# Existing tests...

def test_create_book(mock_db_session):
    response = client.post("/books/", json={
        "title": "Test Book",
        "author": "Test Author",
        "pages": 100,
        "cover_image_url": "http://example.com/cover.jpg"
    })
    assert response.status_code == 200
    assert response.json().get("title") == "Test Book"
    assert response.json().get("author") == "Test Author"
    assert response.json().get("pages") == 100
    assert response.json().get("cover_image_url") == "http://example.com/cover.jpg"

# New tests for cover image loading scenarios

def test_view_book_cover_unsuccessful(mock_db_session):
    mock_db_session.query.return_value.all.return_value = [
        Book(id=1, title="Test Book", author="Test Author", pages=100, cover_image_url="http://example.com/cover.jpg")
    ]
    with patch("fastapi_demo.routers.books.BookInfo") as mock_book_info:
        mock_book_info.side_effect = HTTPException(status_code=500, detail="Images could not be loaded")
        response = client.get("/books/")
        assert response.status_code == 500
        assert response.json().get("detail") == "Images could not be loaded"


def test_book_cover_image_loading_unsuccessful(mock_db_session):
    mock_db_session.query.return_value.all.return_value = [
        Book(id=1, title="Test Book", author="Test Author", pages=100, cover_image_url=None)
    ]
    response = client.get("/books/")
    assert response.status_code == 200
    books = response.json()
    for book in books:
        assert book.get("cover_image_url") is None
        assert book.get("cover_image_url") == "path/to/default/error/image.jpg"
