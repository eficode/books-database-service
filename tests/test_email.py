from fastapi.testclient import TestClient
from fastapi_demo.main import app
from unittest.mock import patch

client = TestClient(app)

@patch("fastapi_demo.routers.email.send_email")
@patch("fastapi_demo.routers.email.get_db")
def test_schedule_email(mock_get_db, mock_send_email):
    mock_db_session = mock_get_db.return_value.__enter__.return_value
    mock_db_session.query.return_value.order_by.return_value.all.return_value = [
        {
            "title": "Book 1",
            "author": "Author 1",
            "sales": 100
        },
        {
            "title": "Book 2",
            "author": "Author 2",
            "sales": 90
        }
    ]

    response = client.post("/schedule-email")
    assert response.status_code == 200
    assert response.json() == {"detail": "Email scheduled"}
    mock_send_email.assert_called_once()

@patch("fastapi_demo.routers.email.get_db")
def test_get_most_sold_books(mock_get_db):
    mock_db_session = mock_get_db.return_value.__enter__.return_value
    mock_db_session.query.return_value.order_by.return_value.all.return_value = [
        {
            "title": "Book 1",
            "author": "Author 1",
            "sales": 100
        },
        {
            "title": "Book 2",
            "author": "Author 2",
            "sales": 90
        }
    ]

    response = client.get("/most-sold-books")
    assert response.status_code == 200
    assert response.json() == [
        {
            "title": "Book 1",
            "author": "Author 1",
            "sales": 100
        },
        {
            "title": "Book 2",
            "author": "Author 2",
            "sales": 90
        }
    ]
