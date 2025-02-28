from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Request, User
from fastapi import HTTPException

client = TestClient(app)

@patch('fastapi_demo.dependencies.get_current_user')
@patch('fastapi_demo.database.get_db')
def test_approve_request_success(mock_get_db, mock_get_current_user):
    mock_get_current_user.return_value = User(id=1, role='middle_manager')
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Request(id=1, status='Pending')
    response = client.post("/requests/1/approve")
    assert response.status_code == 200
    assert response.json().get("status") == "Approved"
    assert response.json().get("message") == "Request approved successfully"

@patch('fastapi_demo.dependencies.get_current_user')
@patch('fastapi_demo.database.get_db')
def test_approve_request_permission_denied(mock_get_db, mock_get_current_user):
    mock_get_current_user.return_value = User(id=1, role='employee')
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    response = client.post("/requests/1/approve")
    assert response.status_code == 403
    assert response.json().get("detail") == "Permission denied"

@patch('fastapi_demo.dependencies.get_current_user')
@patch('fastapi_demo.database.get_db')
def test_approve_request_not_found(mock_get_db, mock_get_current_user):
    mock_get_current_user.return_value = User(id=1, role='middle_manager')
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = None
    response = client.post("/requests/1/approve")
    assert response.status_code == 404
    assert response.json().get("detail") == "Request not found"

@patch('fastapi_demo.dependencies.get_current_user')
@patch('fastapi_demo.database.get_db')
def test_approve_request_failure(mock_get_db, mock_get_current_user):
    mock_get_current_user.return_value = User(id=1, role='middle_manager')
    mock_db_session = MagicMock()
    mock_get_db.return_value = mock_db_session
    mock_db_session.query.return_value.filter.return_value.first.return_value = Request(id=1, status='Pending')
    mock_db_session.commit.side_effect = Exception("Database error")
    response = client.post("/requests/1/approve")
    assert response.status_code == 500
    assert response.json().get("detail") == "Failed to process approval"
