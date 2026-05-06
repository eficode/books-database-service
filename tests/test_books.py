from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.database import get_db, Base, engine
from sqlalchemy.orm import sessionmaker
import pytest

client = TestClient(app)

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="module")
def db_session():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def mock_db_session(db_session):
    db_session.query(Book).delete()
    db_session.commit()
    yield db_session


def test_sort_books_ascending(mock_db_session):
    mock_db_session.add_all([
        Book(title="Book C", author="Author 1", pages=100),
        Book(title="Book A", author="Author 2", pages=200),
        Book(title="Book B", author="Author 3", pages=300)
    ])
    mock_db_session.commit()

    response = client.get("/books/sort?order=asc")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 3
    assert data[0]["title"] == "Book A"
    assert data[1]["title"] == "Book B"
    assert data[2]["title"] == "Book C"


def test_sort_books_descending(mock_db_session):
    mock_db_session.add_all([
        Book(title="Book C", author="Author 1", pages=100),
        Book(title="Book A", author="Author 2", pages=200),
        Book(title="Book B", author="Author 3", pages=300)
    ])
    mock_db_session.commit()

    response = client.get("/books/sort?order=desc")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 3
    assert data[0]["title"] == "Book C"
    assert data[1]["title"] == "Book B"
    assert data[2]["title"] == "Book A"


def test_sort_books_empty_list(mock_db_session):
    response = client.get("/books/sort?order=asc")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 0

    response = client.get("/books/sort?order=desc")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 0