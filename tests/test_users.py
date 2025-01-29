from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from sqlalchemy.orm import Session
from datetime import datetime
import pytest

client = TestClient(app)

@pytest.fixture
def db_session():
    from fastapi_demo.database import SessionLocal
    db = SessionLocal()
    yield db
    db.close()

@pytest.fixture
def setup_data(db_session: Session):
    user_id = 1
    db_session.add_all([
        Book(id=1, title="Old Book", author="Author A", user_id=user_id, release_date=datetime(2020, 1, 1)),
        Book(id=2, title="New Book", author="Author A", user_id=user_id, release_date=datetime(2023, 12, 1))
    ])
    db_session.commit()

def test_get_new_releases(db_session, setup_data):
    user_id = 1
    response = client.get(f"/users/{user_id}/new-releases")
    assert response.status_code == 200
    assert len(response.json()["new_releases"]) == 1
    assert response.json()["new_releases"][0]["title"] == "New Book"

def test_get_new_releases_user_not_found(db_session):
    user_id = 999
    response = client.get(f"/users/{user_id}/new-releases")
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"

def test_get_new_releases_no_new_releases(db_session):
    user_id = 1
    db_session.add(Book(id=3, title="Old Book 2", author="Author B", user_id=user_id, release_date=datetime(2020, 1, 1)))
    db_session.commit()
    response = client.get(f"/users/{user_id}/new-releases")
    assert response.status_code == 204
    assert response.json()["detail"] == "No new releases available"
