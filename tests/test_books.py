from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.database import SessionLocal, engine, Base
import pytest

client = TestClient(app)

@pytest.fixture(scope='module')
def db_session():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    yield db
    db.close()
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope='function')
def setup_books(db_session):
    db_session.add_all([
        Book(title="Book A", author="Author A", genre="Fiction", sales_rank=1),
        Book(title="Book B", author="Author B", genre="Non-Fiction", sales_rank=2)
    ])
    db_session.commit()
    yield
    db_session.query(Book).delete()
    db_session.commit()

def test_get_best_selling_books_no_results(db_session):
    response = client.get("/best_selling_books/")
    assert response.status_code == 200
    assert response.json() == {"message": "No best-selling books are available"}

def test_get_best_selling_books_with_genre_no_results(db_session):
    response = client.get("/best_selling_books/?genre=Science")
    assert response.status_code == 200
    assert response.json() == {"message": "No best-selling books are available"}

def test_get_best_selling_books_with_sort_no_results(db_session):
    response = client.get("/best_selling_books/?sort_by=sales_rank")
    assert response.status_code == 200
    assert response.json() == {"message": "No best-selling books are available"}

def test_get_best_selling_books_with_data(setup_books):
    response = client.get("/best_selling_books/")
    assert response.status_code == 200
    assert len(response.json()["books"]) == 2

def test_get_best_selling_books_with_genre(setup_books):
    response = client.get("/best_selling_books/?genre=Fiction")
    assert response.status_code == 200
    assert len(response.json()["books"]) == 1
    assert response.json()["books"][0]["title"] == "Book A"

def test_get_best_selling_books_with_sort(setup_books):
    response = client.get("/best_selling_books/?sort_by=sales_rank")
    assert response.status_code == 200
    assert response.json()["books"][0]["title"] == "Book A"