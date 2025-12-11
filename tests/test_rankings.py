from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book, Ranking
from unittest.mock import MagicMock

client = TestClient(app)

# Mock database session
mock_db_session = MagicMock()

# Test cases

def test_read_rankings_no_books():
    mock_db_session.query.return_value.all.return_value = []
    response = client.get("/rankings/")
    assert response.status_code == 404
    assert response.json().get("detail") == "No books are ranked"

def test_create_ranking_invalid_rank():
    response = client.post("/rankings/", json={"book_id": 1, "rank": 6})
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid ranking"

def test_update_ranking_invalid_rank():
    mock_db_session.query.return_value.filter.return_value.first.return_value = Ranking(book_id=1, user_id=1, rank=3)
    response = client.put("/rankings/1", json={"rank": 6})
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid ranking"

def test_delete_ranking_not_ranked():
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.delete("/rankings/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not ranked"