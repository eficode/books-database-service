from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.database import SessionLocal, engine
import pytest

client = TestClient(app)

def override_get_db():
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(scope='function')
def db_session():
    Book.metadata.create_all(bind=engine)
    db = SessionLocal()
    yield db
    db.close()
    Book.metadata.drop_all(bind=engine)


def test_search_books_by_color(db_session):
    # Add test data
    book1 = Book(title="Book One", author="Author A", pages=100, color="red")
    book2 = Book(title="Book Two", author="Author B", pages=150, color="blue")
    db_session.add(book1)
    db_session.add(book2)
    db_session.commit()

    # Test single color search
    response = client.get("/books/search/?colors=red")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["color"] == "red"

    # Test multiple colors search
    response = client.get("/books/search/?colors=red,blue")
    assert response.status_code == 200
    assert len(response.json()) == 2

    # Test no books found
    response = client.get("/books/search/?colors=green")
    assert response.status_code == 404
    assert response.json()["detail"] == "No books found with the specified color(s)"
