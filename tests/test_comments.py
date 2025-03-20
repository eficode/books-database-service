from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

# Add Comment to a Book - unsuccessful scenario
def test_add_comment_unsuccessful():
    response = client.post("/books/1/comments/", json={"comment": "Great book!"})
    assert response.status_code == 400
    assert response.json()["detail"] == "Comments are currently disabled"

# View Comments on a Book - unsuccessful scenario
def test_view_comments_unsuccessful():
    response = client.get("/books/1/comments/")
    assert response.status_code == 400
    assert response.json()["detail"] == "Comments are currently disabled"

# Edit a Comment on a Book - unsuccessful scenario
def test_edit_comment_unsuccessful():
    response = client.put("/books/1/comments/1", json={"comment": "Updated comment"})
    assert response.status_code == 400
    assert response.json()["detail"] == "Comments are currently disabled"

# Delete a Comment on a Book - unsuccessful scenario
def test_delete_comment_unsuccessful():
    response = client.delete("/books/1/comments/1")
    assert response.status_code == 400
    assert response.json()["detail"] == "Comments are currently disabled"