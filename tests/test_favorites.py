from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Favorite

client = TestClient(app)

# Test for viewing favorite books page - unsuccessful scenario

def test_view_favorite_books_no_favorites(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/favorites/")
    assert response.status_code == 404
    assert response.json().get("detail") == "You have no favorite books"

# Test for adding a book to favorites - unsuccessful scenario

def test_add_book_to_favorites_already_in_favorites(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Favorite(id=1, user_id=1, book_id=1)
    response = client.post("/favorites/", json={"book_id": 1})
    assert response.status_code == 400
    assert response.json().get("detail") == "The book is already in your favorites"

# Test for removing a book from favorites - unsuccessful scenario

def test_remove_book_from_favorites_not_in_favorites(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/favorites/1")
    assert response.status_code == 400
    assert response.json().get("detail") == "The book is not in your favorites"
