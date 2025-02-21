from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.database import SessionLocal, engine
import pytest

client = TestClient(app)

@pytest.fixture(scope='module')
def db_session():
    Book.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
        Book.metadata.drop_all(bind=engine)


def test_get_best_selling_books_success(db_session):
    # Add test data
    book = Book(title="Test Book", author="Test Author", pages=100, language="en")
    db_session.add(book)
    db_session.commit()

    # Test valid request
    response = client.get("/books/best-sellers/?language=en")
    assert response.status_code == 200
    assert response.json() == {"books": [{"id": book.id, "title": book.title, "author": book.author, "pages": book.pages, "language": book.language}]}


def test_get_best_selling_books_no_books(db_session):
    # Test no books available
    response = client.get("/books/best-sellers/?language=fr")
    assert response.status_code == 404
    assert response.json() == {"detail": "No best-selling books available in the selected language"}


def test_get_best_selling_books_error(db_session):
    # Simulate an error
    with pytest.raises(Exception):
        response = client.get("/books/best-sellers/?language=error")
        assert response.status_code == 500
        assert response.json() == {"detail": "There was an issue retrieving the best-selling books"}
