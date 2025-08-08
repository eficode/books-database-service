from fastapi.testclient import TestClient
from fastapi_demo.main import app
import pytest

client = TestClient(app)

@pytest.fixture
def mock_db_session(mocker):
    mock_session = mocker.patch('fastapi_demo.routers.scan_qr_code.get_db')
    return mock_session


def test_scan_qr_code_invalid():
    response = client.post("/scan-qr-code/", json={"qr_code": "invalid_qr_code"})
    assert response.status_code == 400
    assert response.json().get("detail") == "Invalid QR code"


def test_scan_qr_code_book_not_found(mock_db_session):
    mock_db_session.query().filter().first.return_value = None
    response = client.post("/scan-qr-code/", json={"qr_code": "999"}) # Assuming 999 is a non-existent book ID
    assert response.status_code == 404
    assert response.json().get("detail") == "Book not found"


def test_scan_qr_code_network_issue(mocker):
    mocker.patch("fastapi_demo.routers.scan_qr_code.db.query", side_effect=Exception("Network issue"))
    response = client.post("/scan-qr-code/", json={"qr_code": "1"}) # Assuming 1 is a valid book ID
    assert response.status_code == 500
    assert response.json().get("detail") == "Network issue"
