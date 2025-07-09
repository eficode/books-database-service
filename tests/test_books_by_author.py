from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from fastapi_demo.database import get_db
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import pytest

SQLALCHEMY_DATABASE_URL = 'sqlite:///./test.db'
engine = create_engine(SQLALCHEMY_DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope='module')
def client():
    app.dependency_overrides[get_db] = TestingSessionLocal
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()

@pytest.fixture(scope='module')
def db_session():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    yield db
    db.close()
    Base.metadata.drop_all(bind=engine)

def test_get_books_by_author(client, db_session):
    db_session.add_all([
        Book(title='Book 1', author='Author A', pages=100),
        Book(title='Book 2', author='Author A', pages=150),
        Book(title='Book 3', author='Author B', pages=200)
    ])
    db_session.commit()
    response = client.get('/books/by-author')
    assert response.status_code == 200
    data = response.json()
    assert len(data['authors']) == 2
    assert data['authors'][0]['author'] == 'Author A'
    assert len(data['authors'][0]['books']) == 2
    assert data['authors'][1]['author'] == 'Author B'
    assert len(data['authors'][1]['books']) == 1