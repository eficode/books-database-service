from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Comment
from fastapi_demo.dtos import CommentCreate
from unittest.mock import MagicMock
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session():
    mock_session = MagicMock()
    return mock_session

def test_add_comment_success(mock_db_session):
    mock_db_session.add.return_value = None
    mock_db_session.commit.return_value = None
    mock_db_session.refresh.return_value = None

    response = client.post("/books/1/comments", json={"book_id": 1, "user_id": 1, "content": "Great book!"})
    assert response.status_code == 200
    assert response.json().get("content") == "Great book!"

def test_add_comment_empty_content(mock_db_session):
    response = client.post("/books/1/comments", json={"book_id": 1, "user_id": 1, "content": ""})
    assert response.status_code == 400
    assert response.json().get("detail") == "Comment cannot be empty"

def test_get_comments_for_book(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        Comment(id=1, book_id=1, user_id=1, content="Great book!"),
        Comment(id=2, book_id=1, user_id=2, content="Loved it!")
    ]
    response = client.get("/books/1/comments")
    assert response.status_code == 200
    assert len(response.json()) == 2
    assert response.json()[0].get("content") == "Great book!"
    assert response.json()[1].get("content") == "Loved it!"
