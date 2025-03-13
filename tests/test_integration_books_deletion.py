from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_integration_delete_single_book():
    # Create a book to delete
    response = client.post("/books/", json={
        "title": "Integration Test Book",
        "author": "Integration Author",
        "pages": 123
    })
    assert response.status_code == 200
    book_id = response.json().get("id")

    # Delete the book
    response = client.delete(f"/books/{book_id}")
    assert response.status_code == 200
    assert response.json().get("detail") == "Book deleted"

    # Verify the book is deleted
    response = client.get(f"/books/{book_id}")
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"

def test_integration_bulk_delete_books():
    # Create books to delete
    book_ids = []
    for i in range(2):
        response = client.post("/books/", json={
            "title": f"Integration Test Book {i}",
            "author": f"Integration Author {i}",
            "pages": 123 + i
        })
        assert response.status_code == 200
        book_ids.append(response.json().get("id"))

    # Bulk delete the books
    response = client.delete("/books/bulk", data=json.dumps(book_ids), headers={"Content-Type": "application/json"})
    assert response.status_code == 200
    assert response.json().get("detail") == "Books deleted"

    # Verify the books are deleted
    for book_id in book_ids:
        response = client.get(f"/books/{book_id}")
        assert response.status_code == 404
        assert response.json().get("detail") == "Book not found"
