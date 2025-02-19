from fastapi.testclient import TestClient
from fastapi_demo.main import app
from fastapi_demo.models import Gift

client = TestClient(app)

def test_create_gift():
   response = client.post("/gifts/", json={
     "book_id": 1,
     "recipient_name": "John Doe",
     "recipient_address": "123 Main St",
     "personal_message": "Happy Birthday!",
     "gift_wrap_style": "Festive"
   })
   assert response.status_code == 201
   assert response.json().get("book_id") == 1
   assert response.json().get("recipient_name") == "John Doe"
   assert response.json().get("recipient_address") == "123 Main St"
   assert response.json().get("personal_message") == "Happy Birthday!"
   assert response.json().get("gift_wrap_style") == "Festive"
   assert response.json().get("status") == "pending"


def test_read_gift_success():
   response = client.post("/gifts/", json={
     "book_id": 1,
     "recipient_name": "John Doe",
     "recipient_address": "123 Main St",
     "personal_message": "Happy Birthday!",
     "gift_wrap_style": "Festive"
   })
   gift_id = response.json().get("id")
   response = client.get(f"/gifts/{gift_id}")
   assert response.status_code == 200
   assert response.json().get("book_id") == 1
   assert response.json().get("recipient_name") == "John Doe"
   assert response.json().get("recipient_address") == "123 Main St"
   assert response.json().get("personal_message") == "Happy Birthday!"
   assert response.json().get("gift_wrap_style") == "Festive"
   assert response.json().get("status") == "pending"


def test_read_gift_not_found():
   response = client.get("/gifts/9999")
   assert response.status_code == 404
   assert response.json().get("detail") == "Gift not found"