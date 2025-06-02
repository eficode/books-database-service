from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi import HTTPException
import io

client = TestClient(app)

# Existing tests...

def test_upload_book_cover_unsupported_format(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.post("/books/1/cover", files={"file": ("test.txt", io.BytesIO(b"test content"), "text/plain")})
    assert response.status_code == 400
    assert response.json().get("detail") == "Unsupported image format"

def test_view_book_cover_service_down(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, cover_image="invalid_path.jpg")
    with patch("fastapi.responses.FileResponse", side_effect=Exception):
        response = client.get("/books/1/cover")
        assert response.status_code == 503
        assert response.json().get("detail") == "Image storage service is down"

def test_update_book_cover_exceeds_size(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, cover_image="old_cover.jpg")
    large_file = io.BytesIO(b"a" * (5 * 1024 * 1024 + 1))  # Just over 5 MB
    response = client.put("/books/1/cover", files={"file": ("large_image.jpg", large_file, "image/jpeg")})
    assert response.status_code == 400
    assert response.json().get("detail") == "Image size exceeds the limit"

def test_remove_book_cover_service_down(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100, cover_image="cover.jpg")
    with patch("os.remove", side_effect=Exception):
        response = client.delete("/books/1/cover")
        assert response.status_code == 503
        assert response.json().get("detail") == "Image storage service is down"
