from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_search_books_by_title_no_matches():
    response = client.get("/books/search?title=nonexistent")
    assert response.status_code == 200
    assert response.json() == {"message": "No books found"}


def test_search_books_by_author_no_matches():
    response = client.get("/books/search?author=nonexistent")
    assert response.status_code == 200
    assert response.json() == {"message": "No books found"}


def test_search_books_by_publication_date_no_matches():
    response = client.get("/books/search?publication_date=1900-01-01")
    assert response.status_code == 200
    assert response.json() == {"message": "No books found"}
