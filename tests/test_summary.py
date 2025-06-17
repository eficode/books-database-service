from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.schemas import User
import pytest

client = TestClient(app)

@pytest.fixture
def test_user(db_session):
    user = User(id=1, username="testuser", email="test@example.com")
    db_session.add(user)
    db_session.commit()
    return user

@pytest.fixture
def test_books(db_session, test_user):
    books = [
        Book(title="Book 1", author="Author A", pages=100, user_id=test_user.id),
        Book(title="Book 2", author="Author B", pages=150, user_id=test_user.id),
        Book(title="Book 3", author="Author A", pages=200, user_id=test_user.id)
    ]
    db_session.bulk_save_objects(books)
    db_session.commit()
    return books

def test_get_books_summary_by_writers(client, test_user, test_books):
    response = client.get("/summary/books-by-writers", headers={"Authorization": f"Bearer {test_user.token}"})
    assert response.status_code == 200
    assert "writers" in response.json()
    assert len(response.json()["writers"]) == 2
    assert response.json()["writers"] == [
        {"writer": "Author A", "book_count": 2},
        {"writer": "Author B", "book_count": 1}
    ]

def test_get_books_summary_by_writers_no_books(client, test_user):
    response = client.get("/summary/books-by-writers", headers={"Authorization": f"Bearer {test_user.token}"})
    assert response.status_code == 200
    assert response.json() == {"message": "No books available"}
