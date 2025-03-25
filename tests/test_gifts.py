from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.database import SessionLocal, Base, engine
from fastapi_demo.models import GiftOrder
import pytest

client = TestClient(app)

@pytest.fixture(scope='module')
def setup_database():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope='function')
def db_session(setup_database):
    connection = engine.connect()
    transaction = connection.begin()
    session = SessionLocal(bind=connection)
    yield session
    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture(scope='function')
def client_with_db(db_session):
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    app.dependency_overrides[get_db] = override_get_db
    yield client
    app.dependency_overrides.clear()

# Test cases

def test_create_gift_order_missing_details(client_with_db):
    response = client_with_db.post("/gifts/", json={
        "book_id": 1,
        "recipient_name": "",
        "recipient_address": "",
        "recipient_contact": ""
    })
    assert response.status_code == 400
    assert response.json()["detail"] == "Recipient's delivery details are required"


def test_create_gift_order_success(client_with_db):
    response = client_with_db.post("/gifts/", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St",
        "recipient_contact": "555-1234"
    })
    assert response.status_code == 201
    assert response.json()["recipient_name"] == "John Doe"
    assert response.json()["recipient_address"] == "123 Main St"
    assert response.json()["recipient_contact"] == "555-1234"
    assert response.json()["status"] == "Pending"


def test_read_gift_order_not_found(client_with_db):
    response = client_with_db.get("/gifts/999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Order not found"


def test_read_gift_order_success(client_with_db):
    # First, create an order
    create_response = client_with_db.post("/gifts/", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St",
        "recipient_contact": "555-1234"
    })
    order_id = create_response.json()["id"]
    # Now, read the order
    response = client_with_db.get(f"/gifts/{order_id}")
    assert response.status_code == 200
    assert response.json()["recipient_name"] == "John Doe"
    assert response.json()["recipient_address"] == "123 Main St"
    assert response.json()["recipient_contact"] == "555-1234"
    assert response.json()["status"] == "Pending"