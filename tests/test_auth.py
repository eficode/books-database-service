from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.auth import SECRET_KEY, ALGORITHM, authenticate_user, get_current_user
from jose import jwt

client = TestClient(app)

def test_get_current_user():
    # Create a token for testing
    data = {"sub": "testuser"}
    token = jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

    # Test the endpoint with the token
    response = client.get("/users/me", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json() == {"username": "testuser", "email": None, "disabled": None}

def test_authenticate_user_valid_credentials():
    token = authenticate_user("testuser", "testpassword")
    assert token is not None

def test_authenticate_user_invalid_credentials():
    token = authenticate_user("wronguser", "wrongpassword")
    assert token is None
    # Test the endpoint with an invalid token
    response = client.get("/users/me", headers={"Authorization": "Bearer invalidtoken"})
    assert response.status_code == 401
    assert response.json() == {"detail": "Could not validate credentials"}

def test_get_current_user_valid_token():
    # Create a token for testing
    data = {"sub": "testuser"}
    token = jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

    # Test the endpoint with the token
    response = client.get("/users/me", headers={"Authorization": "Bearer invalidtoken"})
    assert response.status_code == 401
    assert response.json() == {"detail": "Could not validate credentials"}
