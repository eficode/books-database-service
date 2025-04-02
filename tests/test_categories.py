from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_create_category_invalid_name():
    response = client.post("/categories/", json={"name": ""})
    assert response.status_code == 400
    assert response.json().get("detail") == "Category name cannot be empty"

def test_list_books_by_category_no_books():
    # Assuming category with id 1 exists but has no books
    response = client.get("/categories/1/books")
    assert response.status_code == 404
    assert response.json().get("detail") == "No books available in this category"