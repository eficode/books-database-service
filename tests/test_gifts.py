from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Gift
from fastapi import HTTPException
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session(mocker):
    db_session = mocker.patch('fastapi_demo.database.SessionLocal', autospec=True)
    return db_session.return_value

def test_create_gift_missing_details(mock_db_session):
    response = client.post("/gifts/mothers-day", json={
        "book_id": 1,
        "recipient_name": "",
        "recipient_address": ""
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "Recipient details are required"

def test_create_gift_invalid_address(mock_db_session):
    mock_db_session.add.return_value = None
    mock_db_session.commit.return_value = None
    mock_db_session.refresh.return_value = None
    response = client.post("/gifts/mothers-day", json={
        "book_id": 1,
        "recipient_name": "John Doe",
        "recipient_address": "Invalid Address"
    })
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid address"
