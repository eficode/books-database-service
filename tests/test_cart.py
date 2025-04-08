from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

# Test for adding favorite book to shopping cart - unsuccessful scenario
def test_add_to_cart_unsuccessful():
    response = client.post("/cart/", json={"book_id": 1})
    assert response.status_code == 500
    assert response.json()["detail"] == "System error: Unable to add book to shopping cart"