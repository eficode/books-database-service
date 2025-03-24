from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.database import SessionLocal
import pytest

client = TestClient(app)

def override_get_db():
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(scope="module")
def db_session():
    db = SessionLocal()
    yield db
    db.close()

@pytest.fixture(scope="function", autouse=True)
def setup_and_teardown(db_session):
    db_session.query(Book).delete()
    db_session.commit()
    yield
    db_session.query(Book).delete()
    db_session.commit()

def test_search_blue_test_books(db_session):
    # Add test data
    db_session.add(Book(title="Blue Book 1", author="Author A", pages=100, color="blue", type="test"))
    db_session.add(Book(title="Blue Book 2", author="Author B", pages=150, color="blue", type="test"))
    db_session.commit()
    # Test search endpoint
    response = client.get("/books/search?color=blue&type=test")
    assert response.status_code == 200
    assert len(response.json()) == 2
    # Test no books found
    response = client.get("/books/search?color=blue&type=nonexistent")
    assert response.status_code == 404
    assert response.json()["detail"] == "No blue test books found"
