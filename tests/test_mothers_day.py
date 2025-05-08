from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

# Test case for invalid address
def test_send_present_invalid_address(mock_db_session):
    response = client.post('/mothers-day/presents/', json={
        'present_id': 1,
        'recipient_name': 'Mother',
        'recipient_address': 'Invalid Address'
    })
    assert response.status_code == 400
    assert response.json().get('detail') == 'Invalid shipping address'

# Test case for missing address
def test_send_present_missing_address(mock_db_session):
    response = client.post('/mothers-day/presents/', json={
        'present_id': 1,
        'recipient_name': 'Mother',
        'recipient_address': ''
    })
    assert response.status_code == 400
    assert response.json().get('detail') == 'Shipping address is required'

# Test case for API failure
def test_send_present_api_failure(mock_db_session):
    response = client.post('/mothers-day/presents/', json={
        'present_id': 1,
        'recipient_name': 'Mother',
        'recipient_address': 'Valid Address'
    })
    assert response.status_code == 503
    assert response.json().get('detail') == 'Shipping service is unavailable'

# Test case for out-of-stock item
def test_send_present_out_of_stock(mock_db_session):
    response = client.post('/mothers-day/presents/', json={
        'present_id': 1,
        'recipient_name': 'Mother',
        'recipient_address': 'Valid Address'
    })
    assert response.status_code == 400
    assert response.json().get('detail') == 'Item is out of stock'
