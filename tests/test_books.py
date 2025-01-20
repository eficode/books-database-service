from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
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

def test_delete_red_books(client, db_session):
    # Add red and non-red books to the database
    db_session.add(Book(title="Red Book 1", author="Author A", pages=100, color="red"))
    db_session.add(Book(title="Blue Book 1", author="Author B", pages=150, color="blue"))
    db_session.commit()
    # Call the delete endpoint
    response = client.delete("/books/red")
    assert response.status_code == 200
    assert response.json() == {"detail": "All red books removed"}
    # Verify red books are deleted
    remaining_books = db_session.query(Book).all()
    assert len(remaining_books) == 1
    assert remaining_books[0].color != "red"

def test_integration_delete_red_books(client):
    # Add red books via the create endpoint
    client.post("/books/", json={"title": "Red Book 2", "author": "Author C", "pages": 200, "color": "red"})
    # Delete red books
    response = client.delete("/books/red")
    assert response.status_code == 200
    # Verify red books are not retrievable
    response = client.get("/books/")
    books = response.json()
    for book in books:
        assert book["color"] != "red"

def test_e2e_delete_red_books(client):
    # Add red books
    client.post("/books/", json={"title": "Red Book 3", "author": "Author D", "pages": 300, "color": "red"})
    # Delete red books
    client.delete("/books/red")
    # Search for red books
    response = client.get("/books/?color=red")
    assert response.status_code == 200
    assert len(response.json()) == 0
