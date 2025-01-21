from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_get_most_sold_books():
    response = client.get("/sales/most-sold-books")
    assert response.status_code == 200
    assert "books" in response.json()


def test_get_least_sold_books():
    response = client.get("/sales/least-sold-books")
    assert response.status_code == 200
    assert "books" in response.json()
