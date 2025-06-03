from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
import io

client = TestClient(app)

# Mock database session
@patch("fastapi_demo.database.SessionLocal", autospec=True)
def test_upload_book_cover_success(mock_db_session):
    mock_db_session.return_value.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    image_data = io.BytesIO(b"fake image data")
    response = client.post("/books/1/cover", files={"file": ("test.jpg", image_data, "image/jpeg")})
    assert response.status_code == 200
    assert response.json().get("message") == "Book cover image uploaded successfully."

@patch("fastapi_demo.database.SessionLocal", autospec=True)
def test_upload_book_cover_invalid_format(mock_db_session):
    mock_db_session.return_value.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    image_data = io.BytesIO(b"fake image data")
    response = client.post("/books/1/cover", files={"file": ("test.txt", image_data, "text/plain")})
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid image file"

@patch("fastapi_demo.database.SessionLocal", autospec=True)
def test_upload_book_cover_corrupted_file(mock_db_session):
    mock_db_session.return_value.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    with patch("builtins.open", side_effect=Exception("File is corrupted")):
        image_data = io.BytesIO(b"fake image data")
        response = client.post("/books/1/cover", files={"file": ("test.jpg", image_data, "image/jpeg")})
        assert response.status_code == 400
        assert response.json().get("detail") == "File is corrupted"

@patch("fastapi_demo.database.SessionLocal", autospec=True)
def test_upload_book_cover_book_not_found(mock_db_session):
    mock_db_session.return_value.query.return_value.filter.return_value.first.return_value = None
    image_data = io.BytesIO(b"fake image data")
    response = client.post("/books/1/cover", files={"file": ("test.jpg", image_data, "image/jpeg")})
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"
