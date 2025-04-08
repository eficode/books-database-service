from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

# Test for adding book to favorites - unsuccessful scenario
def test_add_to_favorites_unsuccessful():
    response = client.post("/favorites/", json={"book_id": 1})
    assert response.status_code == 500
    assert response.json()["detail"] == "System error: Unable to add book to favorites"

# Test for viewing favorites list - unsuccessful scenario
def test_view_favorites_unsuccessful():
    response = client.get("/favorites/")
    assert response.status_code == 500
    assert response.json()["detail"] == "Loading error: Unable to load favorites list"