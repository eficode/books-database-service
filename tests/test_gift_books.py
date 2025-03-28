from fastapi.testclient import TestClient
from fastapi_demo.main import app
import pytest

client = TestClient(app)

@pytest.fixture(scope='module')
def setup_db():
    from fastapi_demo.database import Base, engine
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

# Test for invalid payment
def test_create_gift_order_invalid_payment(setup_db):
    response = client.post('/gift-books/', json={
        'book_id': 1,
        'recipient_name': 'John Doe',
        'recipient_address': '123 Main St',
        'payment_info': {
            'card_number': 'invalid',
            'expiry_date': '12/23',
            'cvv': '123'
        }
    })
    assert response.status_code == 400
    assert response.json()['detail'] == 'Payment failed'

# Test for missing delivery address
def test_create_gift_order_missing_address(setup_db):
    response = client.post('/gift-books/', json={
        'book_id': 1,
        'recipient_name': 'John Doe',
        'recipient_address': None,
        'payment_info': {
            'card_number': '1234567890123456',
            'expiry_date': '12/23',
            'cvv': '123'
        }
    })
    assert response.status_code == 400
    assert response.json()['detail'] == 'Recipient address is required'