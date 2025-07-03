from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import UserBonus
from fastapi import HTTPException

client = TestClient(app)

def test_get_bonus_points_unsuccessful(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.get("/users/1/bonus_points")
    assert response.status_code == 404
    assert response.json().get("detail") == "User has not viewed their profile"

def test_get_bonus_points_successful(mock_db_session):
    mock_db_session.query.return_value.filter.return_value.first.return_value = UserBonus(user_id=1, bonus_points=100)
    response = client.get("/users/1/bonus_points")
    assert response.status_code == 200
    assert response.json().get("user_id") == 1
    assert response.json().get("total_bonus_points") == 100
