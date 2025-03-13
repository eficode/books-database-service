from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_invite_friends_via_email_success():
    response = client.post("/invite/email", json={"emails": ["test@example.com"]})
    assert response.status_code == 200
    assert response.json() == {"message": "Invitations sent successfully"}


def test_invite_friends_via_email_invalid_email():
    response = client.post("/invite/email", json={"emails": ["invalid-email"]})
    assert response.status_code == 400
    assert response.json() == {"detail": "Invalid email address"}


def test_invite_friends_via_social_success():
    response = client.post("/invite/social", json={"platform": "twitter", "link": "http://example.com"})
    assert response.status_code == 200
    assert response.json() == {"message": "Invitation shared successfully"}


def test_invite_friends_via_social_failure():
    response = client.post("/invite/social", json={"platform": "unknown", "link": "http://example.com"})
    assert response.status_code == 400
    assert response.json() == {"detail": "Failed to share on social media"}
