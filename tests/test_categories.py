from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_create_category(mock_db_session):
    response = client.post("/categories/", json={"name": "Fiction"})
    assert response.status_code == 201
    assert response.json().get("name") == "Fiction"

def test_assign_book_to_category(mock_db_session):
    response = client.post("/categories/1/books/", json={"book_id": 1})
    assert response.status_code == 200
    assert response.json().get("category_id") == 1
    assert response.json().get("book_id") == 1

def test_get_books_by_category(mock_db_session):
    response = client.get("/categories/1/books/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
