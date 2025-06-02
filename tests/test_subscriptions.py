from fastapi.testclient import TestClient
from fastapi_demo.main import app

client = TestClient(app)

# Test for opt-in subscription
def test_opt_in_subscription():
    response = client.post("/subscriptions/opt-in", json={"user_id": 1})
    assert response.status_code == 200
    assert response.json().get("message") == "Subscription confirmed"

# Test for scheduling delivery
def test_schedule_delivery_not_opted_in():
    response = client.post("/deliveries/schedule", json={"user_id": 2})
    assert response.status_code == 400
    assert response.json().get("detail") == "You have not opted-in for monthly book delivery"

# Test for managing subscription
def test_manage_subscription_not_chosen():
    response = client.put("/subscriptions/manage", json={"user_id": 3, "action": "pause"})
    assert response.status_code == 400
    assert response.json().get("detail") == "You have not chosen to manage your subscription"
