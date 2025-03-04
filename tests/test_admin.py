from fastapi.testclient import TestClient
from fastapi_demo.main import app
from unittest.mock import patch

client = TestClient(app)

@patch('fastapi_demo.routers.admin.get_current_admin_user')
@patch('fastapi_demo.routers.admin.get_db')
def test_remove_test_books_success(mock_get_db, mock_get_current_admin_user):
    mock_get_current_admin_user.return_value = {'is_admin': True}
    mock_db_session = mock_get_db.return_value.__enter__.return_value
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.post("/admin/remove-test-books/")
    assert response.status_code == 200
    assert response.json() == {"detail": "All test books have been removed."}

@patch('fastapi_demo.routers.admin.get_current_admin_user')
@patch('fastapi_demo.routers.admin.get_db')
def test_remove_test_books_db_connection_lost(mock_get_db, mock_get_current_admin_user):
    mock_get_current_admin_user.return_value = {'is_admin': True}
    mock_db_session = mock_get_db.return_value.__enter__.return_value
    mock_db_session.query.side_effect = Exception("Database connection lost")
    response = client.post("/admin/remove-test-books/")
    assert response.status_code == 500
    assert response.json() == {"detail": "Database connection lost. Test books were not removed."}

@patch('fastapi_demo.routers.admin.get_current_admin_user')
@patch('fastapi_demo.routers.admin.get_db')
def test_verify_no_test_books_success(mock_get_db, mock_get_current_admin_user):
    mock_get_current_admin_user.return_value = {'is_admin': True}
    mock_db_session = mock_get_db.return_value.__enter__.return_value
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/admin/verify-no-test-books/")
    assert response.status_code == 200
    assert response.json() == {"detail": "No test books found."}

@patch('fastapi_demo.routers.admin.get_current_admin_user')
@patch('fastapi_demo.routers.admin.get_db')
def test_verify_no_test_books_query_timeout(mock_get_db, mock_get_current_admin_user):
    mock_get_current_admin_user.return_value = {'is_admin': True}
    mock_db_session = mock_get_db.return_value.__enter__.return_value
    mock_db_session.query.side_effect = Exception("Query timeout")
    response = client.get("/admin/verify-no-test-books/")
    assert response.status_code == 500
    assert response.json() == {"detail": "Query failed due to a timeout."}