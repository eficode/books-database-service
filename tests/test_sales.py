from fastapi.testclient import TestClient
from fastapi_demo.main import app
from datetime import datetime, timedelta
from fastapi_demo.models import Book
from fastapi_demo.database import SessionLocal

client = TestClient(app)

def setup_module(module):
    # Setup test data
    db = SessionLocal()
    one_week_ago = datetime.now() - timedelta(days=7)
    books = [
        Book(title="Book 1", author="Author 1", pages=100, sale_date=one_week_ago),
        Book(title="Book 2", author="Author 2", pages=150, sale_date=one_week_ago),
        Book(title="Book 1", author="Author 1", pages=100, sale_date=one_week_ago + timedelta(days=1)),
    ]
    db.add_all(books)
    db.commit()
    db.close()


def teardown_module(module):
    # Clean up test data
    db = SessionLocal()
    db.query(Book).delete()
    db.commit()
    db.close()


def test_get_most_sold_books():
    response = client.get("/sales/most-sold-books")
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0
    assert data[0]["title"] == "Book 1"
    assert data[0]["sold_count"] == 2
