from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Bestseller, Cart, Order
from fastapi_demo.database import SessionLocal, engine
import pytest

client = TestClient(app)

# Setup and teardown for database
@pytest.fixture(scope="module")
def setup_module():
    Bestseller.metadata.create_all(bind=engine)
    Cart.metadata.create_all(bind=engine)
    Order.metadata.create_all(bind=engine)
    yield
    Bestseller.metadata.drop_all(bind=engine)
    Cart.metadata.drop_all(bind=engine)
    Order.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def db_session():
    session = SessionLocal()
    yield session
    session.close()

# Test cases

def test_get_bestsellers_no_bestsellers(db_session):
    response = client.get("/bestsellers/2023")
    assert response.status_code == 404
    assert response.json()["detail"] == "No bestsellers available for the selected year"

def test_add_to_cart_out_of_stock(db_session):
    bestseller = Bestseller(id=1, title="Test Book", author="Test Author", year=2023, price=10.0, stock=0)
    db_session.add(bestseller)
    db_session.commit()
    response = client.post("/bestsellers/cart/add", json={"book_id": 1})
    assert response.status_code == 400
    assert response.json()["detail"] == "The bestseller is out of stock"

def test_checkout_payment_failed(db_session):
    bestseller = Bestseller(id=1, title="Test Book", author="Test Author", year=2023, price=10.0, stock=10)
    db_session.add(bestseller)
    db_session.commit()
    cart_item = Cart(user_id=1, book_id=1)
    db_session.add(cart_item)
    db_session.commit()
    response = client.post("/bestsellers/checkout", json={"payment_details": {"card_number": "1234", "expiry_date": "12/23", "cvv": "123"}})
    assert response.status_code == 400
    assert response.json()["detail"] == "Payment failed"