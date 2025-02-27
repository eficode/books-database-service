import pytest
from unittest.mock import patch, MagicMock
from fastapi_demo.scheduler import send_sales_report_email


@patch('fastapi_demo.scheduler.smtplib.SMTP')
@patch('fastapi_demo.scheduler.get_db')
def test_send_sales_report_email(mock_get_db, mock_smtp):
    mock_session = MagicMock()
    mock_get_db.return_value = mock_session
    mock_session.query.return_value.order_by.return_value.limit.return_value.all.side_effect = [
        [
            MagicMock(title='Book A', author='Author A', sales=100),
            MagicMock(title='Book B', author='Author B', sales=90)
        ],
        [
            MagicMock(title='Book C', author='Author C', sales=10),
            MagicMock(title='Book D', author='Author D', sales=5)
        ]
    ]
    mock_server = mock_smtp.return_value.__enter__.return_value

    # Simulate email service down
    mock_server.sendmail.side_effect = smtplib.SMTPException("Email service is down")

    send_sales_report_email()

    mock_server.sendmail.assert_called_once()
    assert mock_server.sendmail.call_count == 1
