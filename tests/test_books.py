from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.database import SessionLocal, Base, engine
import pytest

client = TestClient(app)

@pytest.fixture(scope='module')
def setup_database():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    db.add(Book(title='Book A', author='Author A', pages=100))
    db.add(Book(title='Book B', author='Author B', pages=150))
    db.commit()
    yield db
    db.close()
    Base.metadata.drop_all(bind=engine)


def test_sort_books_ascending(setup_database):
    response = client.get('/books/sort?order=asc')
    assert response.status_code == 200
    books = response.json()
    assert len(books) == 2
    assert books[0]['title'] == 'Book A'
    assert books[1]['title'] == 'Book B'


def test_sort_books_descending(setup_database):
    response = client.get('/books/sort?order=desc')
    assert response.status_code == 200
    books = response.json()
    assert len(books) == 2
    assert books[0]['title'] == 'Book B'
    assert books[1]['title'] == 'Book A'


def test_sort_books_empty_list():
    # Ensure the database is empty
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    response = client.get('/books/sort?order=asc')
    assert response.status_code == 200
    books = response.json()
    assert len(books) == 0
    response = client.get('/books/sort?order=desc')
    assert response.status_code == 200
    books = response.json()
    assert len(books) == 0