from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_read_liked_books_pagination(mock_db_session):
    # Mock liked books
    mock_db_session.query.return_value.filter.return_value.offset.return_value.limit.return_value.all.return_value = [
        {"id": 1, "title": "Liked Book 1", "author": "Author 1", "pages": 100, "favorite": True},
        {"id": 2, "title": "Liked Book 2", "author": "Author 2", "pages": 150, "favorite": True}
    ]

    response = client.get("/books/liked?skip=0&limit=2")
    assert response.status_code == 200
    liked_books = response.json()
    assert len(liked_books) == 2
    assert liked_books[0]["title"] == "Liked Book 1"
    assert liked_books[1]["title"] == "Liked Book 2"

    response = client.get("/books/liked?skip=1&limit=1")
    assert response.status_code == 200
    liked_books = response.json()
    assert len(liked_books) == 1
    assert liked_books[0]["title"] == "Liked Book 2"
