from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Book
from unittest.mock import patch

client = TestClient(app)

@patch('fastapi_demo.utils.get_least_sold_books')
@patch('fastapi_demo.utils.send_email')
def test_generate_least_sold_books_report(mock_send_email, mock_get_least_sold_books):
    mock_get_least_sold_books.return_value = [
        Book(id=1, title='Book 1', author='Author 1', sales=10),
        Book(id=2, title='Book 2', author='Author 2', sales=20)
    ]
    response = client.post('/reports/least-sold-books')
    assert response.status_code == 200
    assert response.json() == {'message': 'Report generation initiated'}
    mock_send_email.assert_called_once()

@patch('fastapi_demo.utils.send_email')
def test_send_email_endpoint(mock_send_email):
    mock_send_email.return_value.status_code = 200
    response = client.post('/email/send', json={
        'to': 'test@example.com',
        'subject': 'Test Subject',
        'body': 'Test Body'
    })
    assert response.status_code == 200
    assert response.json() == {'message': 'Email sent successfully'}
    mock_send_email.assert_called_once()
