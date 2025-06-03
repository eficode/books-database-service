from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
import io

client = TestClient(app)

# Existing tests...

def test_upload_cover_image_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    file = io.BytesIO(b"fake image data")
    response = client.post("/books/1/cover", files={"file": ("test.jpg", file, "image/jpeg")})
    assert response.status_code == 200
    assert response.json().get("message") == "Cover image uploaded successfully"
    assert response.json().get("book_id") == 1
    assert "cover_url" in response.json()


def test_upload_cover_image_unsupported_file_type(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    file = io.BytesIO(b"fake image data")
    response = client.post("/books/1/cover", files={"file": ("test.txt", file, "text/plain")})
    assert response.status_code == 400
    assert response.json().get("detail") == "The file type is not supported"


def test_upload_cover_image_file_too_large(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    file = io.BytesIO(b"a" * (5 * 1024 * 1024 + 1))  # Just over 5 MB
    response = client.post("/books/1/cover", files={"file": ("test.jpg", file, "image/jpeg")})
    assert response.status_code == 400
    assert response.json().get("detail") == "The file size is too large"
