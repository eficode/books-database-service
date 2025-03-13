from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_register_user():
    response = client.post("/auth/register", json={
        "email": "testuser@example.com",
        "password": "password123",
        "first_name": "Test",
        "last_name": "User"
    })
    assert response.status_code == 201
    assert response.json().get("email") == "testuser@example.com"

def test_login_user():
    response = client.post("/auth/jwt/login", data={
        "username": "testuser@example.com",
        "password": "password123"
    })
    assert response.status_code == 200
    assert "access_token" in response.json()
