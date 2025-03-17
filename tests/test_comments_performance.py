from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Comment
from sqlalchemy.orm import Session
import pytest

client = TestClient(app)

@pytest.fixture
def setup_comments(mock_db_session: Session):
    # Add 1000 comments to the database for testing
    comments = [Comment(book_id=1, user_id=i, content=f"Comment {i}") for i in range(1000)]
    mock_db_session.add_all(comments)
    mock_db_session.commit()

def test_retrieve_large_number_of_comments(setup_comments, mock_db_session):
    response = client.get("/books/1/comments")
    assert response.status_code == 200
    assert len(response.json()) == 1000
