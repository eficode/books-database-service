from unittest.mock import patch
from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)


def test_generate_daily_email_report():
    with patch('fastapi_demo.services.report_service.send_daily_report') as mock_send_daily_report:
        response = client.post('/reports/daily-email')
        assert response.status_code == 200
        assert response.json() == {"message": "Daily email report sent successfully"}
        mock_send_daily_report.assert_called_once()
