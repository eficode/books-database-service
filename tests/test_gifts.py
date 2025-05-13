from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

def test_select_book_for_mothers_day_gift_unsuccessful():
    response = client.post(
        "/gifts/mothers-day",
        json={
            "book_id": 1,
            "personal_message": "Happy Mother's Day!"
        }
    )
    assert response.status_code == 400
    assert response.json()["detail"] == "Mother's shipping address is required"

def test_confirm_and_send_gift_unsuccessful_invalid_address():
    response = client.post(
        "/gifts/mothers-day",
        json={
            "book_id": 1,
            "mother_address": {
                "street": "123 Main St",
                "city": "Anytown",
                "state": "CA",
                "zip_code": "00000",
                "country": "USA"
            },
            "personal_message": "Happy Mother's Day!"
        }
    )
    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid shipping address"
