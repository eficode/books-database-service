from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Gift

client = TestClient(app)

# Test creating a gift

def test_create_gift():
    response = client.post("/gifts/", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "123 Main St"
    })
    assert response.status_code == 201
    assert response.json().get("book_id") == 1
    assert response.json().get("recipient_name") == "John Doe"
    assert response.json().get("recipient_address") == "123 Main St"
    assert response.json().get("status") == "Pending"

# Test reading a gift successfully

def test_read_gift_success():
    response = client.get("/gifts/1")
    assert response.status_code == 200
    assert response.json().get("gift_id") == 1
    assert response.json().get("book_id") == 1
    assert response.json().get("recipient_name") == "John Doe"
    assert response.json().get("recipient_address") == "123 Main St"
    assert response.json().get("status") == "Pending"

# Test reading a gift that does not exist

def test_read_gift_not_found():
    response = client.get("/gifts/999")
    assert response.status_code == 404
    assert response.json().get("detail") == "Gift not found"
