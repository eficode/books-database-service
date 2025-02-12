from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Order
from unittest.mock import patch
import pytest

client = TestClient(app)

@pytest.fixture
@patch('fastapi_demo.routers.orders.get_current_user')
@patch('fastapi_demo.database.SessionLocal')
def mock_db_session(mock_session, mock_user):
    mock_user.return_value = {'id': 1}
    yield mock_session

@patch('requests.get')
def test_get_order_status_success(mock_get, mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Order(id=1, user_id=1, book_id=1, status='shipped', estimated_delivery_date='2023-10-10')
    mock_get.return_value.status_code = 200
    mock_get.return_value.json.return_value = {'status': 'shipped', 'estimated_delivery_date': '2023-10-10'}

    response = client.get('/orders/1/status')

    assert response.status_code == 200
    assert response.json() == {
        'order_id': 1,
        'logistical_status': 'shipped',
        'estimated_delivery_date': '2023-10-10'
    }

@patch('requests.get')
def test_get_order_status_order_not_found(mock_get, mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None

    response = client.get('/orders/1/status')

    assert response.status_code == 404
    assert response.json() == {'detail': 'Order not found'}

@patch('requests.get')
def test_get_order_status_service_unavailable(mock_get, mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Order(id=1, user_id=1, book_id=1, status='shipped', estimated_delivery_date='2023-10-10')
    mock_get.return_value.status_code = 503

    response = client.get('/orders/1/status')

    assert response.status_code == 503
    assert response.json() == {'detail': 'Service is currently unavailable'}

@patch('fastapi_demo.routers.orders.get_current_user', return_value=None)
def test_get_order_status_not_authenticated(mock_get_current_user, mock_db_session):
    response = client.get('/orders/1/status')

    assert response.status_code == 401
    assert response.json() == {'detail': 'Not authenticated'}
