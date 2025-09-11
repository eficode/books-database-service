from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.database import SessionLocal, engine
from sqlalchemy.orm import sessionmaker
import pytest

client = TestClient(app)

@pytest.fixture(scope='module')
def db_session():
    connection = engine.connect()
    transaction = connection.begin()
    session = SessionLocal(bind=connection)
    yield session
    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture(autouse=True)
def setup_db(db_session):
    db_session.query(Book).delete()
    db_session.commit()
    book1 = Book(title='Example Book', author='John Doe', pages=123, isbn='1234567890')
    book2 = Book(title='Another Book', author='Jane Doe', pages=456, isbn='0987654321')
    db_session.add(book1)
    db_session.add(book2)
    db_session.commit()
    yield
    db_session.query(Book).delete()
    db_session.commit()

def test_search_books_by_title_no_results(client, db_session):
    response = client.get('/books/search?title=NonExistentTitle')
    assert response.status_code == 404
    assert response.json().get('detail') == 'No books found'

def test_search_books_by_author_no_results(client, db_session):
    response = client.get('/books/search?author=NonExistentAuthor')
    assert response.status_code == 404
    assert response.json().get('detail') == 'No books found'

def test_search_books_by_isbn_no_results(client, db_session):
    response = client.get('/books/search?isbn=0000000000')
    assert response.status_code == 404
    assert response.json().get('detail') == 'No books found'
