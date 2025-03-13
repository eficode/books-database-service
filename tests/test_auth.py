from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_register_user():
    response = client.post("/auth/register", json={
        "email": "test@example.com",
        "password": "password",
        "is_active": True,
        "is_superuser": False,
        "is_verified": False
    })
    assert response.status_code == 201
    assert response.json()["email"] == "test@example.com"

def test_login_user():
    response = client.post("/auth/jwt/login", data={
        "username": "test@example.com",
        "password": "password"
    })
    assert response.status_code == 200
    assert "access_token" in response.json()
