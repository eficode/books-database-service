from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

# Add a book review - unsuccessful scenario
def test_add_review_disabled_text_area():
    response = client.post("/reviews/add", json={"book_id": 1, "review": "Great book!"})
    assert response.status_code == 400
    assert response.json().get("detail") == "Review text area is disabled"
