from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Gift

client = TestClient(app)

def test_create_gift(mock_db_session):
    response = client.post("/gifts/mothers-day", json={
        "user_id": 1,
        "book_id": 1,
        "delivery_address": "123 Main St",
        "delivery_date": "2023-05-14"
    })
    assert response.status_code == 201
    assert response.json().get("user_id") == 1
    assert response.json().get("book_id") == 1
    assert response.json().get("delivery_address") == "123 Main St"
    assert response.json().get("delivery_date") == "2023-05-14"
    assert response.json().get("status") == "scheduled"

def test_read_gift_success(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = Gift(
        id=1, user_id=1, book_id=1, delivery_address="123 Main St", delivery_date="2023-05-14", status="scheduled"
    )
    response = client.get("/gifts/mothers-day/1")
    assert response.status_code == 200
    assert response.json().get("user_id") == 1
    assert response.json().get("book_id") == 1
    assert response.json().get("delivery_address") == "123 Main St"
    assert response.json().get("delivery_date") == "2023-05-14"
    assert response.json().get("status") == "scheduled"

def test_read_gift_not_found(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/gifts/mothers-day/1")
    assert response.status_code == 404
    assert response.json().get("detail") == "Gift not found"
