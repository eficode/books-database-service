from unittest.mock import MagicMock
from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import TestData
from datetime import datetime, timedelta

client = TestClient(app)

# Mock database session
mock_db_session = MagicMock()

# Override the get_db dependency
app.dependency_overrides[get_db] = lambda: mock_db_session

# Test cases
def test_get_outdated_test_data_incomplete():
    mock_db_session.query.return_value.filter.return_value.all.return_value = []
    response = client.get("/test-data/outdated")
    assert response.status_code == 400
    assert response.json()["detail"] == "Incomplete test data"

def test_delete_outdated_test_data_failure():
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        TestData(id=1, data="old data", created_at=datetime.now() - timedelta(days=31))
    ]
    mock_db_session.delete.side_effect = Exception("Deletion failed")
    response = client.delete("/test-data/outdated")
    assert response.status_code == 500
    assert response.json()["detail"] == "Failed to remove outdated test data"

def test_verify_clean_test_environment_failure():
    mock_db_session.query.return_value.filter.return_value.all.return_value = [
        TestData(id=1, data="old data", created_at=datetime.now() - timedelta(days=31))
    ]
    response = client.delete("/test-data/outdated")
    assert response.status_code == 500
    assert response.json()["detail"] == "Failed to remove outdated test data"