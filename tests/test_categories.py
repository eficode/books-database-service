from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Category, Book

client = TestClient(app)

def test_create_category():
    response = client.post("/categories/", json={"name": "Fiction"})
    assert response.status_code == 200
    assert response.json().get("name") == "Fiction"

def test_create_category_missing_info():
    response = client.post("/categories/", json={})
    assert response.status_code == 422

def test_assign_book_to_category():
    # Assuming book with id 1 and category with id 1 exist
    response = client.post("/categories/assign/", json={"book_id": 1, "category_id": 1})
    assert response.status_code == 200
    assert response.json().get("book_id") == 1
    assert response.json().get("category_id") == 1

def test_assign_book_to_non_existent_category():
    # Assuming book with id 1 exists and category with id 999 does not exist
    response = client.post("/categories/assign/", json={"book_id": 1, "category_id": 999})
    assert response.status_code == 404
    assert response.json().get("detail") == "Category not found"

def test_search_books_by_category():
    # Assuming category with id 1 exists
    response = client.get("/categories/1/books")
    assert response.status_code == 200
    # Assuming there are books in the category
    assert len(response.json()) > 0

def test_search_books_by_non_existent_category():
    response = client.get("/categories/999/books")
    assert response.status_code == 404
    assert response.json().get("detail") == "Category not found"
