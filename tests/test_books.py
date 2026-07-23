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
   "pages": 100
  })
  assert response.status_code == 200
  assert response.json().get("title") == "Test Book"
  assert response.json().get("author") == "Test Author"
  assert response.json().get("pages") == 100

# New tests for cover image functionality

def test_get_book_cover_success(mock_db_session):
  mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, cover_image_url="http://example.com/cover.jpg")
  response = client.get("/books/1/cover")
  assert response.status_code == 200
  assert response.json().get("book_id") == 1
  assert response.json().get("cover_image_url") == "http://example.com/cover.jpg"

def test_get_book_cover_not_found(mock_db_session):
  mock_db_session.query.return_value.filter.return_value.first.return_value = None
  response = client.get("/books/1/cover")
  assert response.status_code == 404
  assert response.json().get("detail") == "Book not found"

def test_get_book_cover_no_image(mock_db_session):
  mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, cover_image_url=None)
  response = client.get("/books/1/cover")
  assert response.status_code == 204
  assert response.json().get("detail") == "No cover image available"
