from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, Rating
from fastapi import HTTPException

client = TestClient(app)

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

def test_update_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Old Title", author="Old Author", pages=100)
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200
    })
    assert response.status_code == 200
    assert response.json().get("title") == "New Title"
    assert response.json().get("author") == "New Author"
    assert response.json().get("pages") == 200

def test_update_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.put("/books/1", json={
        "title": "New Title",
        "author": "New Author",
        "pages": 200
    })
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

def test_delete_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.delete("/books/1")
    assert response.status_code == 200
    assert response.json().get("message") == "Book deleted successfully"

def test_delete_book_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/books/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

def test_rate_book_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    with patch("fastapi_demo.routers.books.get_user_id_from_token", return_value=1):
        response = client.post("/books/1/rate", json={"rating": 5})
        assert response.status_code == 200
        assert response.json().get("message") == "Rating submitted successfully"

def test_rate_book_invalid_rating(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    response = client.post("/books/1/rate", json={"rating": 6})
    assert response.status_code == 400
    assert response.json().get("detail") == "Rating must be between 0 and 5"

def test_rate_book_system_down(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Book(id=1, title="Test Book", author="Test Author", pages=100)
    with patch("fastapi_demo.routers.books.get_user_id_from_token", side_effect=Exception("System down")):
        response = client.post("/books/1/rate", json={"rating": 5})
        assert response.status_code == 503
        assert response.json().get("detail") == "The rating system is currently unavailable"

def test_get_average_rating_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = [Rating(book_id=1, user_id=1, rating=5), Rating(book_id=1, user_id=2, rating=3)]
    response = client.get("/books/1/rating")
    assert response.status_code == 200
    assert response.json().get("average_rating") == 4.0

def test_get_average_rating_no_ratings(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/books/1/rating")
    assert response.status_code == 200
    assert response.json().get("average_rating") == 0

def test_get_average_rating_data_corrupted(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.side_effect = Exception("Data corrupted")
    response = client.get("/books/1/rating")
    assert response.status_code == 500
    assert response.json().get("detail") == "The average rating cannot be displayed"
